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
        let nativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey: nativeAppKey as! String)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    

}
