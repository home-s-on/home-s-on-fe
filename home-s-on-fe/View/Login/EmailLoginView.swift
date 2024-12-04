//
//  EmailLogin.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/20/24.
//

import SwiftUI

struct EmailLoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State var email: String = "song@gmail.com"
    @State var password: String = "123456"
    @State private var isEmailSignUpActive = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("로그인")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Group {
                    VStack(alignment: .leading) {
                        Text("이메일")
                            .font(.headline)
                        CustomTextField(icon: "person.fill", placeholder: "ID를 입력하시오.", text: $email)
                    }
                        
                    VStack(alignment: .leading) {
                        Text("비밀번호")
                            .font(.headline)
                        CustomTextField(icon: "lock.fill", placeholder: "비밀번호를 입력하시오.", text: $password, isSecured: true)
                    
                    }
                    
                }.padding(.horizontal)
                    .padding(.top, 10)

                VStack {
                    NavigationLink(destination: loginVM.destinationView(), isActive: $loginVM.isNavigating) {
                        EmptyView()
                    }

                    WideImageButton(icon: "person.badge.key", title: "로그인", backgroundColor: .blue) {
                        print("Login button pressed")
                        loginVM.emailLogin(email: email, password: password)
                        print("isNavigating before login: \(loginVM.isNavigating)")
                    }
                }.padding(.top, 30)

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
                }.padding(.top, 10)

            }
            .padding(.bottom, 120)
            .alert("로그인 실패", isPresented: $loginVM.isLoginShowing) {
                Button("확인") {
                    loginVM.isLoginError = false
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
