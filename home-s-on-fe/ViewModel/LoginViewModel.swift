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
    @Published var isJoinShowing = false
    
    private let endPoint = "http://localhost:5001"
    
//    init(){ // 이렇게 하면 처음 로그인화면 안 보여줌
//        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
//    }
    
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
                            } else {
                                self.isLoginError = true
                                self.message = "데이터 처리 중 오류가 발생했습니다."
                            }
                        } else {
                            self.isLoginError = true
                            self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            self.isLoginShowing = true // 오류 메시지 표시를 위한 플래그 설정
                        }
                    case .failure(let error):
                        // 네트워크 오류 처리
                        self.isLoginError = true
                        if let data = response.data {
                            do {
                                // 서버에서 반환된 오류 메시지를 파싱하여 사용자에게 전달
                                let errorResponse = try JSONDecoder().decode(ApiResponse<EmailLoginData>.self, from: data)
                                self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            } catch {
                                // JSON 디코딩 오류 처리
                                self.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            // 데이터가 없는 경우의 기본 메시지 설정
                            self.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                        self.isLoginShowing = true // 오류 메시지 표시를 위한 플래그 설정
                    }
                }
            }
    }
    
    func emailJoin(email: String, password:String) {
        SVProgressHUD.show()
        let url = "\(endPoint)/api/user"
        let params: Parameters = ["email": email, "password": password]
        AF.request(url, method: .post, parameters: params)
            .responseDecodable(of: ApiResponse<SignUpData>.self) { [weak self] response in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isJoinShowing = true // 에러가 나든 성공을 하든 보여주긴 해야함. 그래서 여기에서 true로 해줌
                    
                    switch response.result {
                        case .success(let apiResponse):
                            if apiResponse.status == "success" {
                                // 회원가입 성공 시 처리
                                self.message = "회원가입이 성공적으로 완료되었습니다."
                                // 추가적인 작업 (예: 로그인 화면으로 이동)
                            } else {
                                // API에서 반환한 실패 메시지 처리
                                self.message = apiResponse.message ?? "회원가입에 실패했습니다."
                            }
                    case .failure(let error):
                        self.isLoginError = true
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<SignUpData>.self, from: data)
                                self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            } catch {
                                self.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            self.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                    }
                }
            }
            SVProgressHUD.dismiss()
        }
}
