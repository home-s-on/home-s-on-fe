import SwiftUI
import Alamofire
import SVProgressHUD

class GetMembersInHouseViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var isGetMembersShowing = false
    @Published var isGetMembersError = false
    @Published var isNavigatingToNext = false
    @AppStorage("houseId") var houseId: Int?
    
    func getMembersInHouse() {
        isLoading = true
        SVProgressHUD.show()
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            SVProgressHUD.dismiss()
            return
        }
        
        let url = "\(APIEndpoints.baseURL)/member/members/\(houseId)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .get, headers: headers)
            .responseDecodable(of: ApiResponse<[HouseInMember]>.self) { [weak self] response in
                print("getMembersInHouse\(response)")
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.status == "success" {
                            if let getMembersInHouseData = apiResponse.data {
                                print("getMembersInHouseData: \(getMembersInHouseData)")
                            } else {
                                print("No house in member data found")
                            }
                        } else {
                            self.isGetMembersShowing = true
                            self.isGetMembersError = true
                            self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            print("API Error Message: \(self.message)")
                        }
                    case .failure(let error):
                        self.isGetMembersShowing = true
                        self.isGetMembersError = true
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<[HouseInMember]>.self, from: data)
                                self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            } catch {
                                self.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            self.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                        print("Network Error Message: \(self.message)")
                    }
                }
            }
    }
}


