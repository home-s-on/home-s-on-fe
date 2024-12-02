import SwiftUI
import Alamofire
import SVProgressHUD

class JoinToHouseViewModel : ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var isJoinToHouseShowing = false
    @Published var isJoinToHouseError = false
    @Published var isNavigatingToMain = false
    
    func joinToHouse(inviteCode: String) {
        isLoading = true
        SVProgressHUD.show()
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            SVProgressHUD.dismiss()
            return
        }
        
        let url = "\(APIEndpoints.baseURL)/house/join"
        let params: Parameters = ["inviteCode": inviteCode]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .post, parameters: params, headers: headers)
                    .responseDecodable(of: ApiResponse<UserHouse>.self) { [weak self] response in
                        print("joinToHouse \(response)")
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.isLoading = false
                            SVProgressHUD.dismiss()
                            
                            switch response.result {
                            case .success(let apiResponse):
                                if apiResponse.status == "success" {
                                    if let joinToHouseData = apiResponse.data {
                                        UserDefaults.standard.set(joinToHouseData.houseId, forKey: "houseId")
                                        UserDefaults.standard.set(joinToHouseData.isOwner, forKey: "isOwner")
                                        self.isNavigatingToMain = true
                                    }
                                } else {
                                    self.isJoinToHouseShowing = true
                                    self.isJoinToHouseError = true
                                    self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                                }
                            case .failure(let error):
                                self.isJoinToHouseShowing = true
                                self.isJoinToHouseError = true
                                if let data = response.data {
                                    do {
                                        let errorResponse = try JSONDecoder().decode(ApiResponse<UserHouse>.self, from: data)
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
