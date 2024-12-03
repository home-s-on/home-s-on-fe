import Alamofire
import SVProgressHUD
import SwiftUI

class HouseEntryOptionsViewModel: ObservableObject {
    @Published var inviteCode: String = ""
    @Published var message = ""
    @Published var isLoading = false

    func createHouse() {
        self.isLoading = true
        SVProgressHUD.show()
        
        let url = "\(APIEndpoints.baseURL)/house/create"
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            SVProgressHUD.dismiss()
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .post, headers: headers)
            .responseDecodable(of: ApiResponse<House>.self) { [weak self] response in
                guard let self = self else { return }
                SVProgressHUD.dismiss()
                
                switch response.result {
                case .success(let apiResponse):
                    if apiResponse.status == "success" {
                        if let createHouseData = apiResponse.data {
                            UserDefaults.standard.set(createHouseData.inviteCode, forKey: "inviteCode")
                            UserDefaults.standard.set(createHouseData.houseId, forKey: "houseId")
                        }
                    } else {
                        self.message = apiResponse.message ?? "Unknown error occurred"
                    }
                case .failure(let error):
                    self.message = "Request failed with error: \(error.localizedDescription)"
                }
            }
    }
}


