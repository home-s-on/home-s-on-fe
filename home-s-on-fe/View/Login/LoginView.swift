import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var isEmailLoginActive = false
    var body: some View {
        NavigationStack {
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
                    
                    HStack {
                        Color.gray
                            .frame(height: 0.5, alignment: .center)
                        Text("또는")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 12, weight: .regular))
                        Color.gray
                            .frame(height: 0.5, alignment: .center)
                    }
                    
                    LoginButton(loginType: .email, text: "email로 시작하기") {
                        print("email")
                        isEmailLoginActive = true
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationDestination(isPresented: $isEmailLoginActive) {
                            EmailLoginView()
                        }
        }
        .onChange(of: loginVM.isLoggedIn) { newValue in
            if newValue {
                print("로그인 성공!")
                ProfileEditView()
                
            } else {
                print("로그아웃됨")
            }
        }
    }
}

#Preview {
    let loginVM = LoginViewModel()
    LoginView().environmentObject(loginVM)
}
