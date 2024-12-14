//
//  TaskManagementModel.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/6/24.
//

import SwiftUI
import Alamofire

class TaskCompleteViewModel: ObservableObject {
    @Published var message = ""
    @Published var isFetchError = false
    @Published var isLoading = false
    @Published var showSuccessAlert = false
    
    func toggleTaskComplete(taskId: Int, completion: @escaping () -> Void) {
        print("토글 시작 - taskId:", taskId)
        print("요청 URL:", "\(APIEndpoints.baseURL)/tasks/\(taskId)/complete")
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("토큰 없음")
            isFetchError = true
            message = "로그인이 필요합니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        print("API 요청 시작")
        AF.request("\(APIEndpoints.baseURL)/tasks/\(taskId)/complete",
                   method: .patch,
                   headers: headers)
        .validate()
        .responseDecodable(of: CompleteTaskResponse<Task>.self) { [weak self] response in
            print("API 응답:", response.result)
            
            switch response.result {
            case .success(let taskResponse):
                print("성공:", taskResponse)
                self?.isFetchError = false
                self?.message = taskResponse.message
                self?.showSuccessAlert = true
                
                // 완료 task & 다음 task 처리
                let completedTask = taskResponse.data.completedTask
                if let nextTask = taskResponse.data.nextTask {
                    print("다음 주 요일의 새로운 할일이 생성되었습니다: \(nextTask.id)")
                    
                } else {
                    print("다음 주 요일의 새로운 할일이 생성되지 않았습니다")
                }
                
    
                completion()
                
            case .failure(let error):
                print("실패:", error)
                self?.isFetchError = true
                if let statusCode = error.responseCode {
                    switch statusCode {
                    case 403:
                        self?.message = "할일 담당자만 완료할 수 있습니다"
                    case 404:
                        self?.message = "할일을 찾을 수 없습니다"
                    default:
                        self?.message = "할일 완료 상태를 변경할 수 없습니다"
                    }
                }
            }
        }
    }
    
    func deleteTask(taskId: Int, completion: @escaping () -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
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
            .validate()
            .responseDecodable(of: DeleteResponse.self) { [weak self] response in
                switch response.result {
                case .success(let response):
                    self?.isFetchError = false
                    self?.message = response.message
                    self?.showSuccessAlert = true
                    completion()
                    
                case .failure(let error):
                    self?.isFetchError = true
                    if let statusCode = error.responseCode {
                        switch statusCode {
                        case 403:
                            self?.message = "삭제 권한이 없습니다"
                        case 404:
                            self?.message = "할일을 찾을 수 없습니다"
                        default:
                            self?.message = "할일을 삭제할 수 없습니다"
                        }
                    }
                }
            }
    }
}

