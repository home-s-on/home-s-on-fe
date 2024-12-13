//
//  AiMotivationViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 12/13/24.
//
import SwiftUI
import Alamofire
import SVProgressHUD

class AiMotivationViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var AiMessage = ""
    @Published var errorOccurred = false
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
    
    func getAiMotivation(completion: @escaping (String) -> Void) {
        isLoading = true
        SVProgressHUD.show()
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            self.errorOccurred = true
            SVProgressHUD.dismiss()
            return
        }
        
        let url = "\(APIEndpoints.baseURL)/chat/motivation"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .post, headers: headers)
            .responseDecodable(of: MotivationChat.self) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.status == "success" {
                            self.AiMessage = apiResponse.message
                            completion(self.AiMessage)
                        } else {
                            self.message = apiResponse.message
                            self.errorOccurred = true
                            completion("동기부여 메시지를 가져오는데 실패했습니다.")
                        }
                    case .failure(let error):
                        self.errorOccurred = true
                        completion("네트워크 오류가 발생했습니다.")
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(MotivationChat.self, from: data)
                                self.message = errorResponse.message
                            } catch {
                                self.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            self.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                        print("Network Error Message: \(self.message)")
                    }
                }
            }
    }
}
