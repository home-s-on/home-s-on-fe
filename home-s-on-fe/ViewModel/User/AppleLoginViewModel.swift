//
//  AppleLoginViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/26/24.
//

import Foundation
import AuthenticationServices
import Alamofire
import SwiftUI

class AppleLoginViewModel: NSObject, ObservableObject {
    public let loginViewModel = LoginViewModel()
    @Published var nextView: String = ""
    @Published var isNavigating = false
    @Published var userId: String?
    @Published var email: String?
    @Published var fullName: PersonNameComponents?
    @Published var isAppleLoggedIn: Bool = false
    
    func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                self.userId = appleIDCredential.user
                self.email = appleIDCredential.email
                self.fullName = appleIDCredential.fullName
                
                if let identityToken = appleIDCredential.identityToken,
                   let idTokenString = String(data: identityToken, encoding: .utf8) {
                    sendToBackend(idToken: idTokenString)
                }
            }
        case .failure(let error):
            print("Apple Sign In failed: \(error.localizedDescription)")
        }
    }
    
    private func sendToBackend(idToken: String) {
        guard let url = URL(string: "\(APIEndpoints.baseURL)/auth/apple") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["authorization": ["id_token": idToken]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        if let data = data {
                            do {
                                let apiResponse = try JSONDecoder().decode(ApiResponse<EmailLoginData>.self, from: data)
                                
                                if apiResponse.status == "success", let loginData = apiResponse.data {
                                    UserDefaults.standard.set(loginData.token, forKey: "token")
                                    UserDefaults.standard.set(loginData.user.id, forKey: "userId")
                                    UserDefaults.standard.set(loginData.user.email, forKey: "email")
                                    UserDefaults.standard.set(loginData.user.nickname ?? "", forKey: "nickname")
                                    UserDefaults.standard.set(loginData.user.photo ?? "", forKey: "photo")
                                    
                                    self.isAppleLoggedIn = true
                                    print("로그인 성공! 토큰:", loginData.token)
                                    self.handleAccountBasedEntry()
                                    self.isNavigating = true
                                } else {
                                    print("로그인 실패:", apiResponse.message ?? "알 수 없는 오류")
                                }
                            } catch {
                                print("JSON 파싱 오류: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Response: \(json)")
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }.resume()
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
                    
                    DispatchQueue.main.async {
                        self.nextView = apiResponse.message ?? "다음뷰"
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
                    if let memberData = apiResponse.data {
                        UserDefaults.standard.set(memberData?.houseId, forKey: "houseId")
                        UserDefaults.standard.set(memberData?.house?.inviteCode, forKey: "inviteCode")
                        print("handleAccountBasedEntry, houseId: \(memberData?.houseId) inviteCode: \(memberData?.house?.inviteCode ?? "No invite code")")
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
    }
    
    @ViewBuilder func destinationView() -> some View {
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
