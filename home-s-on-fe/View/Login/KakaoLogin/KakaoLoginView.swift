//
//  KakaoLoginView.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/27/24.
//

import SwiftUI

struct KakaoLoginView: View {
    @EnvironmentObject var kakaoLoginVM: KakaoLoginViewModel

    var body: some View {
        VStack {
            Button(action: {
                kakaoLoginVM.kakaoLogin()
            }) {
                Image("kakao_login_large_wide")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .padding()
            }

//            // 로그인 후 사용자 정보 표시
//            if let userId = kakaoLoginVM.userId {
//                Text("User ID: \(userId)")
//            }
//            if let email = kakaoLoginVM.email {
//                Text("Email: \(email)")
//            }
        }
    }
}

#Preview {
    let kakaoLoginVM =  KakaoLoginViewModel()
    KakaoLoginView().environmentObject(kakaoLoginVM)
}
