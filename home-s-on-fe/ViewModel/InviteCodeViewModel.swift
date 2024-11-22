//
//  InviteCodeViewModel.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/22/24.
//

import SwiftUI
import Alamofire

class InviteCodeViewModel : ObservableObject {
    @Published var message = ""
    @Published var invitecode = ""
    let endPoint = Bundle.main.infoDictionary?["END_POINT"] as? String
    let getInviteCodePath = Bundle.main.infoDictionary?["GET_INVITE_CODE_PATH"] as? String
    
    func fetchInviteCode(handler:@escaping (String)->Void) {
       
        
        let user_id = 3
        guard let endPoint = endPoint, let getInviteCodePath = getInviteCodePath else { return }
        let url = "\(endPoint)\(getInviteCodePath)\(user_id)"
        //let headers: HTTPHeaders = ["Authorization": ]
        
        print(url)
        AF.request(url, method: .get)
            .response { response in
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200..<300:
                        if let data = response.data {
                            do {
                                let root = try JSONDecoder().decode(InviteCode.self, from: data)
                                self.invitecode = root.inviteCode
                                print(self.invitecode)
                                handler(self.invitecode)
                                self.message = root.status
                               
                            } catch let error {
                                self.message = error.localizedDescription
                            }
                        }
                    case 300..<400:
                           self.message = "리다이렉션이 필요합니다. (상태 코드: \(statusCode))"
                       case 400..<500:
                           switch statusCode {
                           case 400:
                               self.message = "잘못된 요청입니다. (400)"
                           case 401:
                               self.message = "인증이 필요합니다. (401)"
                           case 403:
                               self.message = "접근이 거부되었습니다. (403)"
                           case 404:
                               self.message = "리소스를 찾을 수 없습니다. (404)"
                           default:
                               self.message = "클라이언트 오류가 발생했습니다. (상태 코드: \(statusCode))"
                           }
                       case 500..<600:
                           self.message = "서버 오류가 발생했습니다. (상태 코드: \(statusCode))"
                    default:
                        self.message = "알 수 없는 에러가 발생했습니다"
                    }
                }
            }
        
        
    }
}
