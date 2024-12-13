import SwiftUI
import Alamofire

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var message: String = ""
    @Published var isFetchError: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedAssignee: HouseInMember?
    
    // 모든 할일
    func fetchTasks(houseId: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            isLoading = false
            isFetchError = true
            message = "로그인이 필요합니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request("\(APIEndpoints.baseURL)/tasks/house",
                   method: .get,
                   headers: headers)
        .validate()
        .responseDecodable(of: TaskResponse<Task>.self) { [weak self] response in
            self?.isLoading = false
            
            switch response.result {
            case .success(let taskResponse):
                // 모든 할일을 표시
                self?.tasks = taskResponse.data
                self?.isFetchError = false
                self?.message = ""
                
            case .failure(let error):
                print("Network error:", error)
                self?.isFetchError = true
                self?.message = "할일 목록을 불러올 수 없습니다"
            }
        }
    }

    
    //나의 할일 가져오기
    func fetchMyTasks(userId: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            isLoading = false
            isFetchError = true
            message = "로그인이 필요합니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request("\(APIEndpoints.baseURL)/tasks/mytasks",
                   method: .get,
                   headers: headers)
            .validate()
            .responseDecodable(of: TaskResponse<Task>.self) { [weak self] response in
                self?.isLoading = false
                
                switch response.result {
                case .success(let taskResponse):
                    // 반복 할일 처리
                    let filteredTasks = taskResponse.data.filter { task in
                        // 일반 할일은 모두 표시
                        if task.repeatDay == nil || task.repeatDay?.isEmpty == true {
                            return true
                        }
                        
                        // 반복 할일의 경우 마감일까지의 다음 발생일 확인
                        if let dueDate = self?.dateFromString(task.dueDate ?? ""),
                           let repeatDay = task.repeatDay?.first {
                            let today = Date()
                            let nextDate = Calendar.current.nextDate(
                                after: today,
                                matching: DateComponents(weekday: repeatDay + 1),
                                matchingPolicy: .nextTime
                            )
                            return nextDate != nil && nextDate! <= dueDate
                        }
                        return false
                    }
                    
                    self?.tasks = filteredTasks
                    self?.isFetchError = false
                    self?.message = ""
                    
                case .failure(let error):
                    print("Network error:", error)
                    self?.isFetchError = true
                    self?.message = "할일 목록을 불러올 수 없습니다"
                }
            }
    }
    
    
    // 지난 할일 가져오기
    func fetchPastTasks() {
        guard !isLoading else { return }
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            isLoading = false
            isFetchError = true
            message = "로그인이 필요합니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request("\(APIEndpoints.baseURL)/tasks/pasttasks",
                  method: .get,
                  headers: headers)
            .validate()
            .responseDecodable(of: TaskResponse<Task>.self) { [weak self] response in
                self?.isLoading = false
                
                switch response.result {
                case .success(let taskResponse):
                    let today = Date()
                    self?.tasks = taskResponse.data.filter { task in
                        guard let dueDate = self?.dateFromString(task.dueDate ?? "") else { return false }
                        return dueDate < today
                    }.sorted { (task1, task2) -> Bool in
                        guard let date1 = self?.dateFromString(task1.dueDate ?? ""),
                              let date2 = self?.dateFromString(task2.dueDate ?? "") else { return false }
                        return date1 > date2
                    }
                    
                    if self?.tasks.isEmpty ?? true {
                        self?.isFetchError = true
                        self?.message = "지난 할일이 없습니다"
                    }
                case .failure(let error):
                    print("Error fetching past tasks: \(error.localizedDescription)")
                    self?.isFetchError = true
                    self?.message = "지난 할일을 불러올 수 없습니다"
                }
            }
    }

    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: dateString)
    }
    
    // 할일추가
    var onTaskAdded: (() -> Void)?
    func addTask(houseRoomId: Int, title: String, assigneeId: [Int], memo: String?, alarm: Bool, dueDate: String?,repeatDay: [Int]?) {
            print("=== Add Task Debug Logs ===")
            isLoading = true
            
            guard let token = UserDefaults.standard.string(forKey: "token") else {
                print("Error: Token not found")
                isLoading = false
                isFetchError = true
                message = "로그인이 필요합니다"
                return
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            // 필수 파라미터
            guard !title.isEmpty, houseRoomId > 0, !assigneeId.isEmpty else {
                isLoading = false
                isFetchError = true
                message = "필수 정보를 입력해주세요"
                return
            }
            
            // 파라미터 구성
            var parameters: [String: Any] = [
                "house_room_id": houseRoomId,
                "title": title,
                "assignee_id": assigneeId,
                "alarm": alarm
            ]
            
            // Optional 파라미터
            if let memo = memo, !memo.isEmpty { parameters["memo"] = memo }
//            if let alarm = alarm { parameters["alarm"] = alarm }
            if let dueDate = dueDate, !dueDate.isEmpty { parameters["due_date"] = dueDate }
            //반복요일
            if let repeatDay = repeatDay, !repeatDay.isEmpty {
                parameters["repeat_day"] = repeatDay
                parameters["is_recurring"] = true
                
            }
            
            print("Request parameters:", parameters)
            
            AF.request("\(APIEndpoints.baseURL)/tasks/add",
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: headers)
                .validate(statusCode: [201, 400, 404, 500])
                .responseData { response in
                    self.isLoading = false
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            if response.response?.statusCode == 201 {
                                let taskResponse = try JSONDecoder().decode(AddTaskResponse<Task>.self, from: data)
//                                print("Success: Task created")
//                                print("Task Response:", taskResponse)
                                
                                self.onTaskAdded?()
                                
                                self.isFetchError = false
                                self.message = ""
                            } else {
                                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                                self.isFetchError = true
                                self.message = errorResponse.error
                            }
                        } catch {
                            print("Decoding error:", error)
                            print("Raw data:", String(data: data, encoding: .utf8) ?? "")
                        }
                    case .failure(let error):
                        print("Network error:", error)
                        self.isFetchError = true
                        self.message = "할일을 추가할 수 없습니다"
                    }
                }
        }
    
    //할 일 편집
    var onTaskEdited: (() -> Void)?
    func editTask(taskId: Int, houseRoomId: Int, title: String, assigneeId: [Int], memo: String?, alarm: String?, dueDate: String?) {
        print("=== Edit Task Debug Logs ===")
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let savedHouseId = UserDefaults.standard.string(forKey: "houseId") else {
            print("Error: Token or HouseId not found")
            isLoading = false
            isFetchError = true
            message = "필요한 정보를 찾을 수 없습니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        var parameters: [String: Any] = [
            "house_room_id": houseRoomId,
            "title": title,
            "assignee_id": assigneeId
        ]
        
        if let memo = memo, !memo.isEmpty { parameters["memo"] = memo }
        if let alarm = alarm { parameters["alarm"] = alarm }
        if let dueDate = dueDate, !dueDate.isEmpty { parameters["due_date"] = dueDate }
        
        let url = "\(APIEndpoints.baseURL)/tasks/\(taskId)"
        
        AF.request(url,
                   method: .patch,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
            .validate()
            .responseData { response in
                self.isLoading = false

                
                switch response.result {
                case .success(let data):
                    do {
                        let taskResponse = try JSONDecoder().decode(AddTaskResponse<Task>.self, from: data)
//                        print("Success: Task updated")
//                        self?.fetchTasks(houseId: Int(savedHouseId)!)
                        
                        // 콜백 호출
                        self.onTaskEdited?()
                        
                        self.isFetchError = false
                        self.message = ""
                    } catch {
                        print("Decoding error:", error)
                        self.isFetchError = true
                        self.message = "할일을 수정할 수 없습니다"
                    }
                case .failure(let error):
                    print("Network error:", error)
                    self.isFetchError = true
                    self.message = "할일을 수정할 수 없습니다"

                }
            }
    }
        
        // 할일 삭제
        func deleteTask(taskId: Int) {
            isLoading = true
            
            guard let token = UserDefaults.standard.string(forKey: "token") else {
                isLoading = false
                isFetchError = true
                message = "로그인이 필요합니다"
                return
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request("\(APIEndpoints.baseURL)/tasks/\(taskId)",
                      method: .delete,
                      headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: TaskResponse<Task>.self) { [weak self] response in
                    self?.isLoading = false
                    
                    switch response.result {
                    case .success(let taskResponse):
                        if taskResponse.success {
                            // 성공 시 할일 목록 새로고침
                            if let houseId = self?.tasks.first?.houseId {
                                self?.fetchTasks(houseId: houseId)
                            }
                        } else {
                            self?.isFetchError = true
                            self?.message = "할일을 삭제할 수 없습니다"
                        }
                    case .failure(let error):
                        print("Error:", error)
                        self?.isFetchError = true
                        self?.message = "할일을 삭제할 수 없습니다"
                    }
                }
        }
    }
