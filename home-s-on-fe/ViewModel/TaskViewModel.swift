import SwiftUI
import Alamofire

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var message = ""
    @Published var isFetchError = false
    @Published var isLoading = false
    @Published var selectedAssignee: HouseInMember?
    
    // 모든 할일
    func fetchTasks(houseId: Int) {
        print("=== Fetch Tasks Debug Start ===")
        guard !isLoading else {
            print("Already loading")
            return
        }
        
        print("Checking UserDefaults values:")
        print("Stored token:", UserDefaults.standard.string(forKey: "token") ?? "nil")
        print("Stored houseId:", UserDefaults.standard.string(forKey: "houseId") ?? "nil")
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let savedHouseId = UserDefaults.standard.string(forKey: "houseId"),
              let savedHouseIdInt = Int(savedHouseId) else {
            print("Failed to get token or houseId from UserDefaults")
            isLoading = false
            isFetchError = true
            message = "필요한 정보를 찾을 수 없습니다"
            return
        }
        
        let houseIdToUse = savedHouseIdInt
        print("Using houseId:", houseIdToUse)
        
        isLoading = true
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let url = "\(APIEndpoints.baseURL)/tasks/house"
        let parameters: [String: Any] = ["house_id": houseIdToUse]
        
        print("Request URL:", url)
        print("Parameters:", parameters)
        
        AF.request(url,
                  method: .get,
                  parameters: parameters,
                  encoding: URLEncoding.queryString,
                  headers: headers)
            .validate()
            .responseDecodable(of: TaskResponse<Task>.self) { [weak self] response in
                self?.isLoading = false
                
                switch response.result {
                case .success(let taskResponse):
                    print("Success: Tasks count:", taskResponse.data.count)
                    self?.tasks = taskResponse.data
                    if self?.tasks.isEmpty ?? true {
                        self?.isFetchError = true
                        self?.message = "등록된 할일이 없습니다"
                    } else {
                        self?.isFetchError = false
                        self?.message = ""
                    }
                case .failure(let error):
                    print("Error:", error)
                    if let data = response.data {
                        print("Error response:", String(data: data, encoding: .utf8) ?? "")
                    }
                    self?.isFetchError = true
                    self?.message = "할일 목록을 불러올 수 없습니다"
                }
                
                print("=== End Debug Logs ===\n")
            }
    }
    
    //나의 할일 가져오기
    func fetchMyTasks(userId: Int) {
        print("=== Fetch My Tasks Debug Logs ===")
        print("Starting fetchMyTasks for userId:", userId)
        
        guard !isLoading else {
            print("Loading in progress, skipping fetch")
            return
        }
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("Error: Token not found")
            isLoading = false
            isFetchError = true
            message = "로그인이 필요합니다"
            return
        }
        print("Token:", token)
        print("Request URL:", "\(APIEndpoints.baseURL)/tasks/mytasks")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        print("Request headers:", headers)
        
        AF.request("\(APIEndpoints.baseURL)/tasks/mytasks",
                  method: .get,
                  headers: headers)
            .validate()
            .response { response in
                print("\n=== Response Debug ===")
                print("Status Code:", response.response?.statusCode ?? "No status code")
                print("Raw response:", String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")
            }
            .responseDecodable(of: TaskResponse<Task>.self) { [weak self] response in
                self?.isLoading = false
                
                switch response.result {
                case .success(let taskResponse):
                    print("Success Response:", taskResponse)
                    print("Tasks count:", taskResponse.data.count)
                    self?.tasks = taskResponse.data
                    if self?.tasks.isEmpty ?? true {
                        print("No tasks found")
                        self?.isFetchError = true
                        self?.message = "사용자의 할일 목록이 비어있습니다"
                    }
                case .failure(let error):
                    print("Error:", error)
                    print("Error Description:", error.localizedDescription)
                    if let data = response.data {
                        print("Error response body:", String(data: data, encoding: .utf8) ?? "")
                    }
                    self?.isFetchError = true
                    self?.message = "할일 목록을 불러올 수 없습니다"
                }
                print("=== End Debug Logs ===\n")
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
    func addTask(houseRoomId: Int, title: String, assigneeId: [Int], memo: String?, alarm: String?, dueDate: String?,
        completion: @escaping (Bool) -> Void) {
        print("=== Add Task Debug Logs ===")
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let savedHouseId = UserDefaults.standard.string(forKey: "houseId") else {
            print("Error: Token or HouseId not found")
            isLoading = false
            isFetchError = true
            message = "필요한 정보를 찾을 수 없습니다"
            completion(false)
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
            "assignee_id": assigneeId
        ]
        
        // Optional 파라미터
        if let memo = memo, !memo.isEmpty { parameters["memo"] = memo }
        if let alarm = alarm { parameters["alarm"] = alarm }
        if let dueDate = dueDate, !dueDate.isEmpty { parameters["due_date"] = dueDate }
        
        print("Request parameters:", parameters)
        
        let url = "\(APIEndpoints.baseURL)/tasks/add?house_id=\(savedHouseId)"
        print("Request URL:", url)
        
        AF.request(url,
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
                            let taskResponse = try JSONDecoder().decode(TaskResponse<Task>.self, from: data)
                            print("Success: Task created")
                            print("Task Response:", taskResponse)
                            // 작업 생성 후 저장된 house_id로 fetchTasks 호출
                            self.fetchTasks(houseId: Int(savedHouseId)!)
                            self.isFetchError = false
                            self.message = ""
                            completion(true)
                        } else {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            print("Error Response:", errorResponse)
                            self.isFetchError = true
                            self.message = errorResponse.error
                            completion(false)
                        }
                    } catch {
                        print("Decoding error:", error)
                        print("Raw data:", String(data: data, encoding: .utf8) ?? "")
                        completion(false)
                    }
                case .failure(let error):
                    print("Network error:", error)
                    self.isFetchError = true
                    self.message = "할일을 추가할 수 없습니다"
                    completion(false)
                }
            }
    }
    
    //할일 편집
    func editTask(taskId: Int, houseRoomId: Int, title: String, assigneeId: [Int], memo: String?, alarm: String?, dueDate: String?, completion: @escaping (Bool) -> Void) {
        print("=== Edit Task Debug Logs ===")
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let savedHouseId = UserDefaults.standard.string(forKey: "houseId") else {
            print("Error: Token or HouseId not found")
            isLoading = false
            isFetchError = true
            message = "필요한 정보를 찾을 수 없습니다"
            completion(false)
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
        
        let url = "\(APIEndpoints.baseURL)/api/tasks/edit/\(taskId)?house_id=\(savedHouseId)"
        
        AF.request(url,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .responseData { [weak self] response in
            self?.isLoading = false
            
            switch response.result {
            case .success(let data):
                do {
                    let taskResponse = try JSONDecoder().decode(TaskResponse<Task>.self, from: data)
                    print("Success: Task updated")
                    self?.fetchTasks(houseId: Int(savedHouseId)!)
                    self?.isFetchError = false
                    self?.message = ""
                    completion(true)
                } catch {
                    print("Decoding error:", error)
                    self?.isFetchError = true
                    self?.message = "할일을 수정할 수 없습니다"
                    completion(false)
                }
            case .failure(let error):
                print("Network error:", error)
                self?.isFetchError = true
                self?.message = "할일을 수정할 수 없습니다"
                completion(false)
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
