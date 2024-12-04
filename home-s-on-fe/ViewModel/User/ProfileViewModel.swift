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

    func profileEdit(nickname: String, photoURL: String? = nil, photo: UIImage? = nil) {
        self.isLoading = true
        SVProgressHUD.show()

        let formData = MultipartFormData()
        let basePhotoURL = "\(APIEndpoints.blobURL)"

        // 1. 이미지 파일이 제공된 경우
        if let imageData = photo?.jpegData(compressionQuality: 0.2) {
            print("Photo selected: \(photo)")
            formData.append(imageData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
        }
        // 2. photoURL이 제공된 경우 URL 보완 후 다운로드 시도
        else if let photoURL = photoURL {
            do {
                // 완전한 URL 생성 및 언래핑
                if let fullPhotoURL = URL(string: "\(APIEndpoints.blobURL)/\(photoURL)") {
                    let fileData = try Data(contentsOf: fullPhotoURL)
                    print("Downloaded file data from URL: \(fullPhotoURL)")
                    // formData에 파일 데이터 추가
                    formData.append(fileData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
                } else {
                    // URL 생성 실패 처리
                    print("Invalid photo URL: \(photoURL)")
                    self.message = "잘못된 사진 URL입니다."
                    self.isLoading = false
                    SVProgressHUD.dismiss()
                    return
                }
            } catch {
                // 파일 다운로드 실패 처리
                print("Error downloading file from URL: \(error.localizedDescription)")
                self.message = "파일 다운로드 실패: \(error.localizedDescription)"
                self.isLoading = false
                SVProgressHUD.dismiss()
                return
            }
        }

        // 닉네임 추가
        formData.append(nickname.data(using: .utf8)!, withName: "nickname")

        guard let token = token else { return }

        let url = "\(APIEndpoints.baseURL)/user"
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
                        print("API Response: \(apiResponse)")
                        if apiResponse.status == "success" {
                            if let profileData = apiResponse.data {
                                UserDefaults.standard.set(profileData.nickname, forKey: "nickname")
                                UserDefaults.standard.set(profileData.photo, forKey: "photo")
                            }
                            self?.isProfiledError = false
                            self?.isProfileShowing = true
                            self?.message = apiResponse.message ?? "등록에 성공했습니다."
                            print("Profile updated successfully.")
                        } else {
                            self?.isProfiledError = true
                            self?.message = apiResponse.message ?? "등록에 실패했습니다."
                            self?.isProfileShowing = true
                        }
                    case .failure(let error):
                        self?.isProfiledError = true
                        print("API 호출 실패: \(error.localizedDescription)")
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<User>.self, from: data)
                                self?.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            } catch {
                                self?.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            self?.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                    }
                }
            }
    }
}
