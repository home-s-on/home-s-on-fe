import SwiftUI
import UserNotifications
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct home_s_on_feApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Lifecycle 관리
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var notificationViewModel = NotificationViewModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let nativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String ?? ""
        KakaoSDK.initSDK(appKey: nativeAppKey)
      
        // UserDefaults 초기화
        resetUserDefaults()
        
        // 알림 권한 요청
        requestNotificationAuthorization()
        
        return true
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 중 오류 발생: \(error.localizedDescription)")
            } else if granted {
                print("알림 권한이 허용되었습니다.")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        notificationViewModel.registerDeviceToken(deviceToken) // ViewModel에 디바이스 토큰 전달
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print(error.localizedDescription)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           if (AuthApi.isKakaoTalkLoginUrl(url)) {
               return AuthController.handleOpenUrl(url: url)
           }

           return false
   }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            sceneConfig.delegateClass = SceneDelegate.self
            return sceneConfig
        }
  
   private func resetUserDefaults() {
        let defaults = UserDefaults.standard
            
       defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "nickname")
        defaults.removeObject(forKey: "photo")
        defaults.removeObject(forKey: "inviteCode")
        defaults.removeObject(forKey: "houseId")
        defaults.removeObject(forKey: "isOwner")
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}
