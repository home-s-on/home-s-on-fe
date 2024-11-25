//
//  LoginViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/20/24.
//

import Alamofire
import SVProgressHUD
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoginError = false
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var isLoginShowing = false
    @Published var isJoinShowing = false
    @Published var isNavigatingToLogin = false
    var profileViewModel: ProfileViewModel?
    
//    init(){ // 이렇게 하면 처음 로그인화면 안 보여줌
//        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
//    }
    
    init(profileViewModel: ProfileViewModel? = nil) {
        self.profileViewModel = profileViewModel
            
//            if let token = UserDefaults.standard.string(forKey: "token") {
//                self.isLoggedIn = true
//                self.profileViewModel?.token = token
//            }
    }
    
    func emailLogin(email: String, password: String) {
        isLoading = true
        SVProgressHUD.show()
        
        let url = "\(APIEndpoints.baseURL)/auth/email"
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
                                self.profileViewModel?.token = loginData.token
                                print("로그인 성공! 토큰:", loginData.token)
                            }
                        } else {
                            self.isLoginError = true
                            self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            self.isLoginShowing = true
                        }
                    case .failure(let error):
                        self.isLoginError = true
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<EmailLoginData>.self, from: data)
                                self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
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
    
    func emailJoin(email: String, password: String) {
        SVProgressHUD.show()
        let url = "\(APIEndpoints.baseURL)/user"
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
//                            self.isNavigatingToLogin = true // 로그인 화면으로 이동 플래그 설정
                        } else {
                            // API에서 반환한 실패 메시지 처리
                            self.message = apiResponse.message ?? "회원가입에 실패했습니다."
                            self.isNavigatingToLogin = false
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
                    SVProgressHUD.dismiss()
                }
            }
    }
}
