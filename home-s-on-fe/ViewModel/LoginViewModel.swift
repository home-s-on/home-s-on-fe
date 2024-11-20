//
//  LoginViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/20/24.
//

import SwiftUI
import Alamofire
import SVProgressHUD

class LoginViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoginError = false
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var isLoginShowing = false
    
    private let endPoint = "http://localhost:5001"
    
    init(){ // 이렇게 하면 처음 로그인화면 안 보여줌
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func emailLogin(email: String, password: String) {
        isLoading = true
        SVProgressHUD.show()
        let url = "\(endPoint)/api/auth/email"
        let params: Parameters = ["email": email, "password": password]
        AF.request(url, method: .post, parameters: params)
            .responseDecodable(of: ApiResponse<EmailLoginData>.self) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.status == "success" {
                            if let loginData = apiResponse.data {
                                self.isLoggedIn = true
                                UserDefaults.standard.set(loginData.token, forKey: "token")
                                UserDefaults.standard.set(loginData.user.email, forKey: "email")
                                UserDefaults.standard.set(self.isLoggedIn, forKey: "isLoggedIn")
                            } else {
                                self.isLoginError = true
                                self.message = "데이터 처리 중 오류가 발생했습니다. 1"
                            }
                        } else {
                            self.isLoginError = true
                            self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다. 1"
                            self.isLoginShowing = true
                        }
                    case .failure(let error):
                        self.isLoginError = true
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<EmailLoginData>.self, from: data)
                                self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다. 2"
                            } catch {
                                self.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            self.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                        self.isLoginShowing = true
                    }
                }
            }
    }
}
