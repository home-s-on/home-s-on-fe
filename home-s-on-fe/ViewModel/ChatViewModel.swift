//
//  ChatViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 12/10/24.
//

import SwiftUI
import Alamofire
import SVProgressHUD

class ChatViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var assistantResponse = ""
    @Published var errorOccurred = false
    @Published var chatHistory: [Chat] = []
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")

    func sendChat(userMessage: String) {
        isLoading = true
        SVProgressHUD.show()
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            self.errorOccurred = true
            SVProgressHUD.dismiss()
            return
        }
        
        let url = "\(APIEndpoints.baseURL)/chat"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["userMessage": userMessage]
        
        AF.request(url, method: .post, parameters: params, headers: headers)
            .responseDecodable(of: ApiResponse<SendChat>.self) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.status == "success" {
                            if let sendChatData = apiResponse.data {
                                self.assistantResponse = sendChatData.assistantResponse
                                // 새로운 채팅 메시지를 chatHistory에 추가
                                let newChat = Chat(id: self.chatHistory.count + 1,
                                        userId: self.userId,
                                       userMessage: userMessage,
                                       assistantResponse: sendChatData.assistantResponse)
                                self.chatHistory.append(newChat)
                            } else {
                                self.message = "응답 데이터가 없습니다."
                                self.errorOccurred = true
                            }
                        } else {
                            self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            self.errorOccurred = true
                        }
                    case .failure(let error):
                        self.errorOccurred = true
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<SendChat>.self, from: data)
                                self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
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
    
    func getChat() {
        isLoading = true
        SVProgressHUD.show()
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            self.errorOccurred = true
            SVProgressHUD.dismiss()
            return
        }
        
        let url = "\(APIEndpoints.baseURL)/chat"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .get, headers: headers)
                .responseDecodable(of: ApiResponse<GetChat>.self) { [weak self] response in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        SVProgressHUD.dismiss()
                        
                        switch response.result {
                        case .success(let apiResponse):
                            if apiResponse.status == "success" {
                                if let getChatData = apiResponse.data {
                                    self.chatHistory = getChatData.existingChat
                                } else {
                                    self.message = "채팅 기록이 없습니다."
                                    self.errorOccurred = true
                                }
                            } else {
                                self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                                self.errorOccurred = true
                            }
                        case .failure(let error):
                            self.errorOccurred = true
                            if let data = response.data {
                                do {
                                    let errorResponse = try JSONDecoder().decode(ApiResponse<GetChat>.self, from: data)
                                    self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
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
