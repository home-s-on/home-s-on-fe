import SwiftUI
import Alamofire
import SVProgressHUD

class GetHouseIdViewModel: ObservableObject {
    @Published var message = ""
    @Published var isLoading = false
    @Published var isJoinToHouseShowing = false
    @Published var isJoinToHouseError = false
    @Published var isNavigatingToMain = false
    
    func getHouseId(inviteCode: String, completion: @escaping (Int?) -> Void) {
        isLoading = true
        SVProgressHUD.show()
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            self.message = "토큰이 존재하지 않습니다."
            self.isLoading = false
            SVProgressHUD.dismiss()
            completion(nil) // 실패 시 nil 반환
            return
        }
        
        let url = "\(APIEndpoints.baseURL)/house/gethouseId"
        let params: Parameters = ["inviteCode": inviteCode]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .post, parameters: params, headers: headers)
            .responseDecodable(of: ApiResponse<HouseId>.self) { [weak self] response in
                print("getHouseId \(response)") // 응답 내용 출력
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    SVProgressHUD.dismiss()
                    
                    switch response.result {
                    case .success(let apiResponse):
                        if apiResponse.status == "success" {
                            if let getHouseIdData = apiResponse.data {
                                UserDefaults.standard.set(getHouseIdData.id, forKey: "houseId") // houseId 저장
                                print("Found houseId: \(getHouseIdData.id)") // 찾은 houseId 출력
                                completion(getHouseIdData.id) // houseId 반환
                            } else {
                                print("No house data found") // 데이터가 없으면 로그 출력
                                completion(nil)
                            }
                        } else {
                            self.isJoinToHouseShowing = true
                            self.isJoinToHouseError = true
                            self.message = apiResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            print("API Error Message: \(self.message)") // 오류 메시지 로그 출력
                            completion(nil) // 실패 시 nil 반환
                        }
                    case .failure(let error):
                        self.isJoinToHouseShowing = true
                        self.isJoinToHouseError = true
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(ApiResponse<HouseId>.self, from: data)
                                self.message = errorResponse.message ?? "알 수 없는 오류가 발생했습니다."
                            } catch {
                                self.message = "데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                            }
                        } else {
                            self.message = "네트워크 오류: \(error.localizedDescription)"
                        }
                        print("Network Error Message: \(self.message)") // 네트워크 오류 로그 출력
                        completion(nil)
                    }
                }
            }
    }
}
