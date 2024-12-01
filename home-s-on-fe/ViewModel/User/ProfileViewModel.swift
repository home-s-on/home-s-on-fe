import Alamofire
import SVProgressHUD
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var isProfileShowing = false
    @Published var isProfiledIn = false
    @Published var isProfiledError = false
    @Published var isNavigatingToEntry = false
    @AppStorage("token") var token: String?
    let BASE_URL = Bundle.main.infoDictionary?["BASE_URL"] ?? ""
    
    func profileEdit(nickname: String, photo: UIImage?, completion: @escaping (Bool) -> Void) {
        isLoading = true
        SVProgressHUD.show()
        
        let formData = MultipartFormData()
        if let imageData = photo?.jpegData(compressionQuality: 0.2) {
            formData.append(imageData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
        }
        formData.append(nickname.data(using: .utf8)!, withName: "nickname")
        
        guard let token = token else {
            print("Token is nil")
            isLoading = false
            SVProgressHUD.dismiss()
            completion(false) // 실패 상태 전달
            return
        }
        
        let url = "\(BASE_URL)/user"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: formData, to: url, method: .put, headers: headers)
            .responseDecodable(of: ApiResponse<User>.self) { [weak self] response in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.status == "success" {
                            if let profileData = apiResponse.data {
                                UserDefaults.standard.set(profileData.nickname, forKey: "nickname")
                                UserDefaults.standard.set(profileData.photo, forKey: "photo")
                            }
                            self?.isProfiledError = false
                            self?.isProfileShowing = true
                            completion(true) // 성공 상태 전달
                        } else {
                            self?.isProfiledError = true
                            self?.message = apiResponse.message ?? "등록에 실패했습니다."
                            completion(false) // 실패 상태 전달
                        }
                    case .failure:
                        self?.isProfiledError = true
                        self?.message = "네트워크 오류: \(response.error?.localizedDescription ?? "알 수 없는 오류")"
                        completion(false) // 실패 상태 전달
                    }
                }
            }
    }
}
