//
//  ProfileViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/21/24.
//

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
//    var token: String {
//        return UserDefaults.standard.string(forKey: "token") ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzMyNTQwMTM3LCJleHAiOjE3MzI2MjY1Mzd9.gqxfNNYLw46RBcLZNzfZScG4Y0lUBiPITaEKfL9yl-c"
//    }
    
    func profileEdit(nickname: String, photo: UIImage?) {
        isLoading = true
        SVProgressHUD.show()
        
        let formData = MultipartFormData()
        if let imageData = photo?.jpegData(compressionQuality: 0.2) {
            formData.append(imageData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
        }
        formData.append(nickname.data(using: .utf8)!, withName: "nickname")
        
        guard let token = token else {
            print("Token is nil") // 토큰이 nil인 경우 로그 추가
            return
        }

        let url = "\(APIEndpoints.baseURL)/user"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data"
        ]
        
        print("Uploading to URL: \(url)") // 업로드할 URL 로그 추가

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
                            print("Profile updated successfully.")
                        } else {
                            self?.isProfiledError = true
                            self?.message = apiResponse.message ?? "등록에 실패했습니다."
                        }
                    case .failure(let error):
                        self?.isProfiledError = true
                        print("API 호출 실패: \(error.localizedDescription)") // 에러 로그 추가
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
