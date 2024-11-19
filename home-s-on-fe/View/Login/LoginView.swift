import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .center, spacing: 15) {
                LoginButton(loginType: .kakao, text: "카카오로 시작하기") {
                    print("카카오")
                }
                
                LoginButton(loginType: .naver, text: "네이버로 시작하기") {
                    print("네이버")
                }
                
                LoginButton(loginType: .google, text: "Google로 시작하기") {
                    print("구글")
                }
                
                LoginButton(loginType: .apple, text: "Apple로 시작하기") {
                    print("애플")
                }
            }
            
            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    LoginView()
}
