//
//  ProfileViewModel.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/21/24.
//

import SwiftUI
import Alamofire
import SVProgressHUD

class ProfileViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var isProfileShowing = false
    @AppStorage("token") var token:String?
    
    
    func profileEdit(nickname: String, photo: UIImage?) {
        isLoading = true
        SVProgressHUD.show()
        
        let formData = MultipartFormData()
        if let imageData = photo?.jpegData(compressionQuality: 0.2) {
                formData.append(imageData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
            }
        formData.append(nickname.data(using: .utf8)!, withName: "nickname")
        
        guard let token = token else { return }

        let url = "\(APIEndpoints.baseURL)/user"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data"
        ]
        print("요청 URL:", url)
//        print("요청 헤더:", headers)
        
        AF.upload(multipartFormData: formData, to: url, method: .put, headers: headers)
            .responseDecodable(of: ApiResponse<User>.self) { [weak self] response in
                print(response)
                if let statusCode = response.response?.statusCode {
                            print("Status Code: \(statusCode)")
                        }
                        
                        if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                            print("Response Body: \(responseString)")
                        }
                DispatchQueue.main.async {
                    self?.isProfileShowing = true
                    self?.isLoading = false
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.status == "success" {
                            self?.message = "닉네임과 프로필이 성공적으로 등록되었습니다."
                        } else {
                            self?.message = apiResponse.message ?? "등록에 실패했습니다."
                        }
                    case .failure(let error):
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<User>.self, from: data)
                                self?.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            } catch {
                                // 디코딩 오류에 대한 상세 메시지 출력
                                print("디코딩 오류:", error)
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
