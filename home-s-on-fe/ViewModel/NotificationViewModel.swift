import SwiftUI
import Alamofire
import SVProgressHUD

class NotificationViewModel: ObservableObject {
    @Published var isNotificationEnabled: Bool = false
    
    init() {
        checkNotificationStatus()
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    self.isNotificationEnabled = true
                case .denied:
                    self.isNotificationEnabled = false
                case .notDetermined:
                    self.requestNotificationPermission()
                default:
                    break
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.isNotificationEnabled = true
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    self.isNotificationEnabled = false
                }
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
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("디바이스 토큰이 성공적으로 서버에 전송되었습니다. 응답: \(value)")
                case .failure(let error):
                    print("Error sending device token to server: \(error.localizedDescription)")
                }
            }
    }
}
