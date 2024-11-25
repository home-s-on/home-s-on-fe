import SwiftUI
import Alamofire

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var message = ""
    @Published var isShowingTasks = false
    @Published var isFetchError = false
    @Published var isLoading = false
   
    //모든 할일
    func fetchTasks(houseId: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        let url = "\(APIEndpoints.baseURL)/api/tasks/house/\(houseId)"
        
        AF.request(url, method: .get)
            .responseDecodable(of: TaskResponse.self) { response in
                self.isLoading = false
                
                switch response.result {
                case .success(let taskResponse):
                    self.tasks = taskResponse.data
                    if self.tasks.isEmpty {
                        self.isFetchError = true
                        self.message = "등록된 할일이 없습니다"
                    }
                    
                case .failure(let error):
                    self.isFetchError = true
                    self.message = "데이터를 불러올 수 없습니다: \(error.localizedDescription)"
                }
            }
    }
    // 나의 할일 가져오기
        func fetchMyTasks(userId: Int) {
            guard !isLoading else { return }
            isLoading = true
            
            let url = "\(APIEndpoints.baseURL)/api/tasks/mytasks/\(userId)"
            
            AF.request(url, method: .get)
                .responseDecodable(of: TaskResponse.self) { response in
                    self.isLoading = false
                    
                    switch response.result {
                    case .success(let taskResponse):
                        self.tasks = taskResponse.data
                        if self.tasks.isEmpty {
                            self.isFetchError = true
                            self.message = "사용자의 할일 목록이 비어있습니다."
                        }
                        
                    case .failure(let error):
                        self.isFetchError = true
                        self.message = "할일 목록을 가져올 수 없습니다: \(error.localizedDescription)"
                    }
                }
        }
    }
