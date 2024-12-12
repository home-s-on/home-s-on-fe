import SwiftUI
import Alamofire
import SVProgressHUD

class NotificationViewModel: ObservableObject {
    @Published var isNotificationEnabled: Bool = false
    @Published var deviceToken: String = ""
    
    init() {
        checkNotificationStatus{ _ in }
    }
    
    func checkNotificationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = settings.authorizationStatus == .authorized
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func checkDeviceToken() {
        if let token = UserDefaults.standard.string(forKey: "deviceToken"){
            self.deviceToken = token
        } else {
            //deviceToken 이 없는 경우, 원격 알림 등록 프로세스 다시 시작
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
            
    }
    
    func requestNotificationPermission(completion: @escaping (Bool)->(Void)) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationEnabled = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                if let error = error {
                    print("알람 권한 요청 중 오류 발생: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    func registerDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        print("APNS device token: \(tokenString)")
        UserDefaults.standard.set(tokenString, forKey: "deviceToken")//userid와 함께 백엔드에 보내줘야 함. apn sever에서는 앞에 보냈던거랑 비교해서 보내기.
        
    }
    
    func sendDeviceTokenToServer(deviceToken: String) {
        
        //guard let userId = UserDefaults.standard.string(forKey: "userId"),
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("사용자 ID 또는 token을 찾을 수 없습니다.")
            return
        }
        
        let url = "\(APIEndpoints.baseURL)/user/update-device-token"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        let params: Parameters = ["deviceToken": deviceToken]
        
        AF.request(url, method: .post, parameters: params, headers: headers)
            .responseDecodable(of: ApiResponse<User?>.self) { [weak self] response in
                
                guard let self = self else { return }
                
                switch response.result {
                case .success(let value):
                    if value.status == "success" {
                        print("디바이스 토큰이 성공적으로 서버에 전송되었습니다. ") // 응답: \(value)
                    } else {
                        print("등록 실패 \(value.message)")
                    }
                case .failure(let error):
                    print("Error sending device token to server: \(error.localizedDescription)")
                }
            }
    }
}
