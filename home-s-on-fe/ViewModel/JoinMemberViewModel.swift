//
//  JoinMemberViewModel.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 12/1/24.
//

import SwiftUI
import Alamofire
import SVProgressHUD

class JoinMemberViewModel : ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var isJoinMemberShowing = false
    @Published var isJoinMemberError = false
    @Published var isNavigatingToMain = false
    @AppStorage("houseId") var houseId: Int?
    
    func joinMember(houseId: Int) {
        isLoading = true
        SVProgressHUD.show()
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            SVProgressHUD.dismiss()
            return
        }
        print("houseId \(houseId)")
        let url = "\(APIEndpoints.baseURL)/member/join/\(houseId)"
        let params: Parameters = ["houseId": houseId]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .post, parameters: params, headers: headers)
                    .responseDecodable(of: ApiResponse<Member>.self) { [weak self] response in
                        print("joinMember \(response)")
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.isLoading = false
                            SVProgressHUD.dismiss()
                            
                            switch response.result {
                            case .success(let apiResponse):
                                if apiResponse.status == "success" {
                                    self.isNavigatingToMain = true
                                } else {
                                    self.isJoinMemberShowing = true
                                    self.isJoinMemberError = true
                                    self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                                }
                            case .failure(let error):
                                self.isJoinMemberShowing = true
                                self.isJoinMemberError = true
                                if let data = response.data {
                                    do {
                                        let errorResponse = try JSONDecoder().decode(ApiResponse<Member>.self, from: data)
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


}
