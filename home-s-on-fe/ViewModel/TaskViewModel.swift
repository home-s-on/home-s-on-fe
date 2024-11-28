import SwiftUI
import Alamofire

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var message = ""
    @Published var isFetchError = false
    @Published var isLoading = false
    
    // 모든 할일
    func fetchTasks(houseId: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("Token not found")
            isLoading = false
            isFetchError = true
            message = "로그인이 필요합니다"
            return
        }
        
        print("Using token:", token)
        print("Request URL:", "\(APIEndpoints.baseURL)/tasks/house")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request("\(APIEndpoints.baseURL)/tasks/house",
                  method: .get,
                  headers: headers)
            .validate()
            .response { response in
                print("Raw response:", String(data: response.data ?? Data(), encoding: .utf8) ?? "")
            }
            .responseDecodable(of: TaskResponse<Task>.self) { [weak self] response in
                self?.isLoading = false
                
                if let statusCode = response.response?.statusCode {
                    print("Response status code:", statusCode)
                }
                
                switch response.result {
                case .success(let taskResponse):
                    print("Decoded response:", taskResponse)
                    self?.tasks = taskResponse.data
                    if self?.tasks.isEmpty ?? true {
                        self?.isFetchError = true
                        self?.message = "등록된 할일이 없습니다"
                    }
                case .failure(let error):
                    print("Error details:", error)
                    if let data = response.data {
                        print("Error response:", String(data: data, encoding: .utf8) ?? "")
                    }
                    self?.isFetchError = true
                    self?.message = "할일 목록을 불러올 수 없습니다"
                }
            }
    }
    
    // 나의 할일 가져오기
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
                    self?.tasks = taskResponse.data
                    if self?.tasks.isEmpty ?? true {
                        self?.isFetchError = true
                        self?.message = "사용자의 할일 목록이 비어있습니다"
                    }
                case .failure(let error):
                    print("Error:", error)
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
                        self?.tasks = taskResponse.data
                        if self?.tasks.isEmpty ?? true {
                            self?.isFetchError = true
                            self?.message = "지난 할일이 없습니다"
                        }
                    case .failure(let error):
                        print("Error:", error)
                        self?.isFetchError = true
                        self?.message = "지난 할일을 불러올 수 없습니다"
                    }
                }
        }
    }

