import SwiftUI
import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import Alamofire

class KakaoLoginViewModel: ObservableObject {
    public let loginViewModel = LoginViewModel()
    @Published var userId: String?
    @Published var email: String?
    @Published var isKakaoLoggedIn: Bool = false
    @Published var nextView: String = ""
    @Published var isNavigating: Bool = false

    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let token = token?.accessToken {
                    self.sendTokenToBackend(token: token)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let token = token?.accessToken {
                    self.sendTokenToBackend(token: token)
                }
            }
        }
    }

    private func sendTokenToBackend(token: String) {
        guard let url = URL(string: "\(APIEndpoints.baseURL)/auth/kakao") else { return }

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

            if let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(ApiResponse<EmailLoginData>.self, from: data)
                    if apiResponse.status == "success", let loginData = apiResponse.data {
                        // UserDefaults에 저장
                        UserDefaults.standard.set(loginData.token, forKey: "token")
                        UserDefaults.standard.set(loginData.user.id, forKey: "userId")
                        UserDefaults.standard.set(loginData.user.email, forKey: "email")
                        UserDefaults.standard.set(loginData.user.nickname ?? "", forKey: "nickname")
                        UserDefaults.standard.set(loginData.user.photo ?? "", forKey: "photo")

                        DispatchQueue.main.async {
                            self.isKakaoLoggedIn = true
                            self.handleAccountBasedEntry()
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

    func handleAccountBasedEntry() {
        let token = UserDefaults.standard.string(forKey: "token")
        let url = "\(APIEndpoints.baseURL)/user"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token ?? "")"]

        AF.request(url, method: .get, headers: headers)
            .responseDecodable(of: ApiResponse<Member?>.self) { [weak self] response in
                guard let self = self else { return }

                switch response.result {
                case .success(let apiResponse):
                    DispatchQueue.main.async {
                        self.nextView = apiResponse.message ?? "다음뷰"
                        self.isNavigating = true
                    }

                    if apiResponse.message == "entry 뷰로 진입합니다." {
                        if let houseId = apiResponse.houseId,
                           let inviteCode = apiResponse.inviteCode {
                            UserDefaults.standard.set(houseId, forKey: "houseId")
                            UserDefaults.standard.set(inviteCode, forKey: "inviteCode")
                        }
                    }

                    if let memberData = apiResponse.data {
                        UserDefaults.standard.set(memberData?.houseId, forKey: "houseId")
                        UserDefaults.standard.set(memberData?.house?.inviteCode, forKey: "inviteCode")
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
        case "main 뷰로 진입합니다.":
            MainView()
        case "entry 뷰로 진입합니다.":
            HouseEntryOptionsView()
        default:
            Text("알 수 없는 뷰: \(nextView)")
        }
    }
}
