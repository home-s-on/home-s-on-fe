//
//  EmailLogin.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/20/24.
//

import SwiftUI

struct EmailLogin: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            VStack {
                CustomTextField(icon: "person.fill", placeholder: "ID를 입력하시오.", text: $email)
                CustomTextField(icon: "lock.fill", placeholder: "비밀번호를 입력하시오.", text: $password, isSecured: true)
            }.padding(.bottom, 20)
            
            VStack {
                WideImageButton(icon: "person.fill", title: "로그인", backgroundColor: .blue) {
                    loginVM.emailLogin(email: email, password: password)
                }
            }
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
#Preview {
    let loginVM = LoginViewModel()
    EmailLogin().environmentObject(loginVM)
}
