//
//  home_s_on_feApp.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/18/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct home_s_on_feApp: App {
    init() {
        // Kakao SDK 초기화
        let nativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey: nativeAppKey as! String)
        
        // UserDefaults 초기화
        resetUserDefaults()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func resetUserDefaults() {
        let defaults = UserDefaults.standard
            
        // 특정 키에 대한 값 삭제
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "nickname")
        defaults.removeObject(forKey: "photo")
        
        // 모든 UserDefaults 데이터 삭제 (선택 사항)
        // if let bundleID = Bundle.main.bundleIdentifier {
        //     defaults.removePersistentDomain(forName: bundleID)
        // }
    }

}
