import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var isEmailLoginActive = false
    @State private var isProfileEditActive = false
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
            .navigationDestination(isPresented: $isProfileEditActive) {
                ProfileEditView()
                    .environmentObject(profileVM)
            }

            NavigationLink(destination: ProfileEditView(), isActive: $loginVM.isLoggedIn) {
                EmptyView()
            }
        }
        .onChange(of: loginVM.isLoggedIn) { newValue in
            print("로그인 상태 변화: \(newValue)")
            if newValue {
                print("로그인 성공!")
                profileVM.token = loginVM.profileViewModel?.token // 로그인 후 프로필 ViewModel에 토큰 전달
                isProfileEditActive = true // 프로필 편집 화면으로 이동
            } else {
                print("로그아웃됨")
            }
        }
    }
}

#Preview {
    let loginVM = LoginViewModel()
    let profileVM = ProfileViewModel()
    LoginView().environmentObject(loginVM).environmentObject(profileVM)
}
