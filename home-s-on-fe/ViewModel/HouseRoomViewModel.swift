//
//  HouseRoomViewModel.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/27/24.
//

import SwiftUI
import Alamofire

class HouseRoomViewModel: ObservableObject {
    @Published var rooms: [HouseRoom] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchRooms() {
        isLoading = true
        print("Fetching rooms...")
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("No token found")
            isLoading = false
            errorMessage = "로그인이 필요합니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)", 
            "Content-Type": "application/json"
        ]
        
        AF.request("\(APIEndpoints.baseURL)/rooms",
                  method: .get,
                  headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: RoomResponse.self) { [weak self] response in
                self?.isLoading = false
                
                if let statusCode = response.response?.statusCode {
//                    print("Response status code:", statusCode)
                }
                
                if let data = response.data {
                    print("Response data:", String(data: data, encoding: .utf8) ?? "")
                }
                
                switch response.result {
                case .success(let responseData):
                    self?.rooms = responseData.data
                case .failure(let error):
//                    print("Error details:", error)
                    self?.errorMessage = "구역 목록을 불러올 수 없습니다"
                }
            }
    }
    
    func addRoom(name: String) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            errorMessage = "로그인이 필요합니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = ["room_name": name]
        
        AF.request("\(APIEndpoints.baseURL)/rooms",
                  method: .post,
                  parameters: parameters,
                  encoding: JSONEncoding.default,
                  headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: RoomResponse.self) { [weak self] response in
                print("Add room response:", response)
                
                switch response.result {
                case .success(let responseData):
                    if responseData.success {
                        self?.fetchRooms()
                    } else {
                        self?.errorMessage = "구역을 추가할 수 없습니다"
                    }
                case .failure(let error):
                    print("Error adding room:", error)
                    self?.errorMessage = "구역을 추가할 수 없습니다"
                }
            }
    }

    func deleteRoom(id: Int) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            errorMessage = "로그인이 필요합니다"
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request("\(APIEndpoints.baseURL)/rooms/\(id)",
                  method: .delete,
                  headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: RoomResponse.self) { [weak self] response in
                print("Delete room response:", response)
                
                switch response.result {
                case .success(let responseData):
                    if responseData.success {
                        self?.fetchRooms()
                        print("구역 추가 성공!") // 디버깅용
                    } else {
                        self?.errorMessage = "구역을 삭제할 수 없습니다"
                    }
                case .failure(let error):
                    print("Error deleting room:", error)
                    if let data = response.data {
//                        print("Error response:", String(data: data, encoding: .utf8) ?? "")
                    }
                    self?.errorMessage = "구역을 삭제할 수 없습니다"
                }
            }
    }
}
