import SwiftUI
import UserNotifications
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct home_s_on_feApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            if isLoading {
                            SplashScreenView()
                                .onAppear {
                                    // 로딩 시간 제어 (예: API 호출, 초기 설정)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isLoading = false
                                    }
                                }
            } else {
                ContentView()
            }
        }
    }
}
/** 1차 안 */
//struct SplashScreenView: View {
//    var body: some View {
//        ZStack {
//            Color.white
//                .edgesIgnoringSafeArea(.all)
//            Image("LaunchLogo") // LaunchLogo는 Assets에 추가된 이미지 이름
//                .resizable()
//                .scaledToFit()
//                .frame(width: 200, height: 200) // 크기 조정
//        }
//    }
//}

/** 2차 안 */
struct SplashScreenView: View {
//    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.mainColor
                .edgesIgnoringSafeArea(.all)
            Image("homeson-logo-w") // LaunchLogo는 Assets에 추가된 이미지 이름
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // 크기 조정
//                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
//                        scale = 1.0
                        opacity = 1.0
                    }
                }
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
        
        UNUserNotificationCenter.current().delegate = self
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
    
    //앱 실행 중
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let info = notification.request.content.userInfo
        print(info["name"] ?? "")
        //앱 실행 중 알람 동작
        completionHandler([.banner, .sound])
    }
    
    //로컬? 알림 응답 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        print(info["name"] ?? "")
        completionHandler()
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
