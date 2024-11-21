//
//  EmailLogin.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/20/24.
//

import SwiftUI

struct EmailLoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State private var isEmailSignUpActive = false
    @State private var isLoginSuccessful = false // 로그인 성공 여부

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    CustomTextField(icon: "person.fill", placeholder: "ID를 입력하시오.", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "비밀번호를 입력하시오.", text: $password, isSecured: true)
                }.padding(.bottom, 20)
                
                VStack {
                    WideImageButton(icon: "person.badge.key", title: "로그인", backgroundColor: .blue) {
                        loginVM.emailLogin(email: email, password: password)
                    }
                }.padding(.bottom, 20)
                
                HStack {
                    Text("계정이 없으신가요?")
                        .font(.subheadline)
                    
                    NavigationLink(destination: EmailSignUpView(), isActive: $isEmailSignUpActive) {
                        Text("회원가입")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                isEmailSignUpActive = true
                            }
                    }
                }
                
                NavigationLink("", destination: MainView(), isActive: $loginVM.isLoggedIn)
            }
            .alert("로그인 실패", isPresented: $loginVM.isLoginShowing) {
                Button("확인") {
                    loginVM.isLoginShowing = false
                }
            } message: {
                Text(loginVM.message)
            }
        }

    }
}

#Preview {
    let loginVM = LoginViewModel()
    EmailLoginView().environmentObject(loginVM)
}
