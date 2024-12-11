//
//  LoginButton.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/19/24.
//

import SwiftUI

struct LoginButton: View {
    var loginType: LoginType
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text(text)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(loginType.textColor)
                    Spacer()
                }
                .frame(height: 45)
                .background(
                    Group {
                        switch loginType {
                        case .google:
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(.gray, lineWidth: 1.5)
                        default:
                            loginType.backGroundColor
                        }
                    }
                )
                .cornerRadius(10)

                loginType.logoImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(loginType.textColor)
                    .offset(x: 80)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LoginButton(loginType: .kakao, text: "카카오로 로그인") {
            print("Kakao login tapped")
        }
        LoginButton(loginType: .google, text: "구글로 로그인") {
            print("Google login tapped")
        }
        LoginButton(loginType: .apple, text: "Apple로 로그인") {
            print("Apple login tapped")
        }
    }
    .padding()
}
