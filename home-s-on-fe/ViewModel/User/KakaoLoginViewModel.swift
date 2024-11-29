//
//  KakaoLoginViewModel.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/27/24.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

class KakaoLoginViewModel: ObservableObject {
    @Published var userId: String?
    @Published var email: String?
    @Published var isKakaoLoggedIn: Bool = false
    let BASE_URL = Bundle.main.infoDictionary?["BASE_URL"] ?? ""

    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let token = token?.accessToken {
                    print(token)
                    self.sendTokenToBackend(token: token)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let token = token?.accessToken {
                    print(token)
                    self.sendTokenToBackend(token: token)
                }
            }
        }
    }

    private func sendTokenToBackend(token: String) {
        guard let url = URL(string: "\(BASE_URL)/auth/kakao") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["token": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending token to backend: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }

            if let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(ApiResponse<EmailLoginData>.self, from: data)
                    print(apiResponse)
                    if apiResponse.status == "success", let loginData = apiResponse.data {
                        // UserDefaults에 저장
                        UserDefaults.standard.set(loginData.token, forKey: "token")
                        UserDefaults.standard.set(loginData.user.email, forKey: "email")
                        UserDefaults.standard.set(loginData.user.nickname ?? "", forKey: "nickname")
                        UserDefaults.standard.set(loginData.user.photo ?? "", forKey: "photo")

                        DispatchQueue.main.async {
                            self.isKakaoLoggedIn = true 
                            print("로그인 성공! 토큰:", loginData.token)
                        }
                    } else {
                        print("로그인 실패:", apiResponse.message ?? "알 수 없는 오류")
                    }
                } catch {
                    print("JSON 파싱 오류: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
