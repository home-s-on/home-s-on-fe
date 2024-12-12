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
    @Published var isJoinError = false
    @Published var isNavigatingToLogin = false
    var profileViewModel: ProfileViewModel?
    @Published var nextView: String = ""
    @Published var isNavigating = false
    @ObservedObject var notificationViewModel = NotificationViewModel()
    
    
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
                                //self.isLoggedIn = true
                                UserDefaults.standard.set(loginData.user.id, forKey: "userId")
                                UserDefaults.standard.set(loginData.token, forKey: "token")
                                UserDefaults.standard.set(loginData.user.email, forKey: "email")
                                UserDefaults.standard.set(loginData.user.photo, forKey: "photo")
                                UserDefaults.standard.set(loginData.user.nickname, forKey: "nickname")
                                
                                if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken"){
                                    self.notificationViewModel.sendDeviceTokenToServer(deviceToken: deviceToken)
                                } else {
                                    self.notificationViewModel.checkDeviceToken()
                                }
                                self.handleAccountBasedEntry()
                            }
                        } else {
                            self.isLoginShowing = true
                            self.isLoginError = true
                            self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                        }
                    case .failure(let error):
                        self.isLoginShowing = true
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
                            self.isJoinError = false

//                            self.isNavigatingToLogin = true // 로그인 화면으로 이동 플래그 설정
                        } else {
                            // API에서 반환한 실패 메시지 처리
                            self.message = apiResponse.message ?? "회원가입에 실패했습니다."
                            self.isJoinError = true
//                            self.isNavigatingToLogin = false
                        }
                    case .failure(let error):
                        self.isJoinError = false
//                        self.isNavigatingToLogin = false
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
    
    func handleAccountBasedEntry() {
        let token = UserDefaults.standard.string(forKey: "token")
        let url = "\(APIEndpoints.baseURL)/user"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token ?? "")"]
            
            AF.request(url, method: .get, headers: headers)
                .responseDecodable(of: ApiResponse<Member?>.self) { [weak self] response in

                    guard let self = self else { return }
                    
                    switch response.result {
                    case .success(let apiResponse):
                        print("API Response for account-based entry: \(apiResponse)")
                        self.nextView = apiResponse.message ?? "다음뷰"
                        DispatchQueue.main.async {
                            self.isNavigating = true
                            print("Navigating to view after login")
                        }
                        if apiResponse.message == "entry 뷰로 진입합니다." {
                                if let houseId = apiResponse.houseId,
                                   let inviteCode = apiResponse.inviteCode {
                                    UserDefaults.standard.set(houseId, forKey: "houseId")
                                    UserDefaults.standard.set(inviteCode, forKey: "inviteCode")
                                    print("handleAccountBasedEntry, houseId: \(houseId) inviteCode: \(inviteCode)")
                                }
                            }

                            // 두 번째 경우: data 안에 house_id와 House의 invite_code가 포함된 경우
                            if let memberData = apiResponse.data {
                                UserDefaults.standard.set(memberData?.houseId, forKey: "houseId")
                                UserDefaults.standard.set(memberData?.house?.inviteCode, forKey: "inviteCode")
                                print("handleAccountBasedEntry, houseId: \(memberData?.houseId) inviteCode: \(memberData?.house?.inviteCode ?? "No invite code")")
                            }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        self.message = "데이터를 가져오는 데 실패했습니다."
                    }
                }
        }
    
    @ViewBuilder
        func destinationView() -> some View {
            let trimmedNextView = nextView.trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch trimmedNextView {
            case "profile 뷰로 진입합니다.":
                ProfileEditView()
                    .onAppear { print("destinationView to ProfileEditView") }
            case "main 뷰로 진입합니다.":
                MainView()
                    .onAppear { print("destinationView to MainView") }
            case "entry 뷰로 진입합니다.":
                HouseEntryOptionsView()
                    .onAppear { print("destinationView to EntryView") }
            default:
                Text("알 수 없는 뷰: \(nextView)")
                    .onAppear { print("unknown view: \(self.nextView)") }
            }
        }
}
