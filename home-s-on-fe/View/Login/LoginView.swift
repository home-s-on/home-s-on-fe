import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var appleLoginVM = AppleLoginViewModel()
    @StateObject var kakaoLoginVM = KakaoLoginViewModel()
    @StateObject var notificationViewModel = NotificationViewModel()
    
    @State private var isEmailLoginActive = false
    @State private var selectedLoginMethod: String? = nil
    @State private var navigateToProfileEdit = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    
                    Image("homeson-logo") // 이미지 추가
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding()
                    
                        
                    
                    
                    LoginButton(loginType: .kakao, text: "kakao로 로그인") {
                        kakaoLoginVM.kakaoLogin()
                    }.onChange(of: kakaoLoginVM.isKakaoLoggedIn) { newValue in
                        if newValue {
                            selectedLoginMethod = "kakao"
                        }
                    }
                    

                    AppleLoginView()
                        .environmentObject(appleLoginVM)
                        .onChange(of: appleLoginVM.isAppleLoggedIn) { newValue in
                            if newValue {
                                selectedLoginMethod = "apple"
                            }
                        }.padding(.horizontal,-17)

                    HStack {
                        Color.gray.frame(height: 0.5)
                        Text("또는").foregroundColor(Color.gray).font(.system(size: 12))
                        Color.gray.frame(height: 0.5)
                    }

                    LoginButton(loginType: .email, text: "email로 로그인") {
                        isEmailLoginActive = true
                    }
                    .background(Color.mainColor) .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 10)
                    
//                    Text("HOME'S ON을 계속 진행하면 서비스 약관에 동의하고\n 개인정보 보호정책을 읽은것으로 간주됩니다.")
//                        .font(.footnote)
//                        .padding(.top, 100)
                }

                Spacer()
                Text("HOME'S ON을 계속 진행하면 서비스 약관에 동의하고\n 개인정보 보호정책을 읽은것으로 간주됩니다.")
                    .font(.footnote)
                    .padding(.top, 90)
            }
            .padding(20)
            .navigationDestination(isPresented: $isEmailLoginActive) {
                EmailLoginView()
            }
            .navigationDestination(for: String.self) { method in
                switch method {
                case "kakao", "naver", "google", "apple":
                    ProfileEditView()
                default:
                    EmptyView()
                }
            }
            .onChange(of: selectedLoginMethod) { newValue in
                if let method = newValue {
                    navigateToProfileEdit = true
                    if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken"){
                        self.notificationViewModel.sendDeviceTokenToServer(deviceToken: deviceToken)
                        
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToProfileEdit) {
                ProfileEditView()
            }
            
            
        }
    }
}

#Preview {
    let loginVM = LoginViewModel()
    let profileVM = ProfileViewModel()
    let houseEntryOptionsVM = HouseEntryOptionsViewModel()
    let appleLoginVM = AppleLoginViewModel()
    LoginView().environmentObject(loginVM).environmentObject(profileVM)
        .environmentObject(houseEntryOptionsVM)
        .environmentObject(appleLoginVM)
}
