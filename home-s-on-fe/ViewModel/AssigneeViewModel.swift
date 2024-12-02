//
//  AssigneeViewModel.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/2/24.
//

import SwiftUI
import Alamofire

class AssigneeViewModel: ObservableObject {
    @Published var houseMembers: [HouseMember] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchHouseMembers() {
        print("=== Fetch House Members Debug Logs ===")
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let houseId = UserDefaults.standard.string(forKey: "houseId") else {
            print("Error: Token or HouseId not found")
            print("Token:", UserDefaults.standard.string(forKey: "token") ?? "nil")
            print("HouseId:", UserDefaults.standard.string(forKey: "houseId") ?? "nil")
            return
        }
        
        print("Token:", token)
        print("HouseId:", houseId)
        
        isLoading = true
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        // URL 경로 수정
        let url = "\(APIEndpoints.baseURL)/members/\(houseId)"

        print("Request URL:", url)
        print("Request headers:", headers)
        
        AF.request(url,
                  method: .get,
                  headers: headers)
            .validate(statusCode: 200...299)
            .responseDecodable(of: HouseMemberResponse.self) { [weak self] response in
                self?.isLoading = false
                print("\n=== Decoding Debug ===")
                
                switch response.result {
                case .success(let memberResponse):
                    print("Success: Members count:", memberResponse.data.count)
                    print("Members data:", memberResponse.data)
                    self?.houseMembers = memberResponse.data
                case .failure(let error):
                    print("Error:", error)
                    print("Error Description:", error.localizedDescription)
                    if let data = response.data {
                        print("Error response body:", String(data: data, encoding: .utf8) ?? "")
                    }
                    self?.errorMessage = error.localizedDescription
                }
                
                print("=== End Debug Logs ===\n")
            }
    }
}
