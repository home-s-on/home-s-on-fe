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
    
    func profileEdit(nickname:String, img_url: String) {
        isLoading = true
        SVProgressHUD.show()
        
        let url = "\(APIEndpoints.baseURL)/api/user"
        let params: Parameters = ["nickname":nickname,"img_url":img_url]
        
        AF.request(url, method: .put, parameters: params)
            .responseDecodable(of: ApiResponse<User>.self) { [weak self] response in
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
                                self?.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            self?.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                    }
                }
            }
            SVProgressHUD.dismiss()
        }
}
