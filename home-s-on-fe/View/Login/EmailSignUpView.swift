//
//  EmailSignUpView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/20/24.
//

import SwiftUI

struct EmailSignUpView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        NavigationView { // NavigationView로 감싸기
            VStack {
                VStack {
                    CustomTextField(icon: "person.fill", placeholder: "ID를 입력하시오.", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "비밀번호를 입력하시오.", text: $password, isSecured: true)
                }.padding(.bottom, 20)

                VStack {
                    WideImageButton(icon: "person.badge.plus", title: "회원가입", backgroundColor: .blue) {
                        loginVM.emailJoin(email: email, password: password)
                    }
                }.padding(.bottom, 20)

                // 회원가입 성공 시 로그인 화면으로 이동
                NavigationLink(destination: EmailLoginView(), isActive: $loginVM.isNavigatingToLogin) {
                    EmptyView()
                }
            }
            .alert("회원가입", isPresented: $loginVM.isJoinShowing) {
                Button("확인") {
                    DispatchQueue.main.async {
                        if loginVM.isJoinError {
                            loginVM.isNavigatingToLogin = true
                        }
                        loginVM.isJoinShowing = false
                    }
                }
            } message: {
                Text(loginVM.message)
            }
        }
    }
}

#Preview {
    let loginVM = LoginViewModel()
    EmailSignUpView().environmentObject(loginVM)
}
