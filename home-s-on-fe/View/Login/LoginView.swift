import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject var appleLoginVM = AppleLoginViewModel()
    
    @State private var isEmailLoginActive = false
    @State private var selectedLoginMethod: String? = nil
    @State private var navigateToProfileEdit = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 15) {
                    LoginButton(loginType: .kakao, text: "카카오로 시작하기") {
                        selectedLoginMethod = "kakao"
                    }
                    
                    LoginButton(loginType: .naver, text: "네이버로 시작하기") {
                        selectedLoginMethod = "naver"
                    }
                    
                    LoginButton(loginType: .google, text: "Google로 시작하기") {
                        selectedLoginMethod = "google"
                    }

                    AppleLoginView()
                        .environmentObject(appleLoginVM)
                        .onChange(of: appleLoginVM.isAppleLoggedIn) { newValue in
                            if newValue {
                                selectedLoginMethod = "apple"
                            }
                        }

                    HStack {
                        Color.gray.frame(height: 0.5)
                        Text("또는").foregroundColor(Color.gray).font(.system(size: 12))
                        Color.gray.frame(height: 0.5)
                    }

                    LoginButton(loginType: .email, text: "email로 시작하기") {
                        isEmailLoginActive = true
                    }
                }

                Spacer()
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
