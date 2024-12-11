//
//  AppleLoginViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/26/24.
//

import Foundation
import AuthenticationServices

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
                                    UserDefaults.standard.set(loginData.user.email, forKey: "email")
                                    UserDefaults.standard.set(loginData.user.nickname ?? "", forKey: "nickname")
                                    UserDefaults.standard.set(loginData.user.photo ?? "", forKey: "photo")
                                    
                                    self.isAppleLoggedIn = true
                                    print("로그인 성공! 토큰:", loginData.token)
                                    self.loginViewModel.handleAccountBasedEntry()
                                    self.nextView = self.loginViewModel.nextView
                                    self.isNavigating = self.loginViewModel.isNavigating
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
}
