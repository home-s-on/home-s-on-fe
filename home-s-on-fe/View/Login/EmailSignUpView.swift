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
    @State var confirmPassword: String = ""
    @State var isEmailValid:Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("회원가입")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Group {
                    VStack(alignment: .leading) {
                        Text("이메일")
                            .font(.headline)
                        CustomTextField(icon: "person.fill", placeholder: "ID로 사용할 이메일을 입력해주세요.", text: $email)
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("비밀번호")
                            .font(.headline)
                        CustomTextField(icon: "lock.fill", placeholder: "비밀번호를 입력하시오.", text: $password, isSecured: true)
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("비밀번호 확인")
                            .font(.headline)
                        CustomTextField(icon: "lock.fill", placeholder: "비밀번호를 한 번 더 입력해주세요.", text: $confirmPassword, isSecured: true)
                    }.padding(.horizontal)
                    
                }.padding(.top, 10)
                   

                VStack {
                    WideImageButton(icon: "person.badge.plus", title: "회원가입", backgroundColor: .mainColor) {
                        
                        // 입력 유효성 검사
                        if isValidEmail(email) {
                            isEmailValid = true
                        } else {
                            loginVM.message = "유효한 이메일 주소를 입력하세요."
                            loginVM.isJoinShowing = true
                            return
                        }
                        
                        guard password.count >= 6 else {
                            loginVM.message = "비밀번호는 최소 6자 이상이어야 합니다."
                            loginVM.isJoinShowing = true
                            return
                        }
                        
                        if password == confirmPassword {
                            loginVM.emailJoin(email: email, password: password)
                        } else {
                            loginVM.message = "비밀번호가 일치하지 않습니다."
                            loginVM.isJoinShowing = true
                        }
                    }
                }.padding(.top, 30)

                NavigationLink(destination: EmailLoginView(), isActive: $loginVM.isNavigatingToLogin) {
                        EmptyView()
                    }
            }.padding(.bottom, 120)
            .alert("회원가입", isPresented: $loginVM.isJoinShowing) {
                Button("확인") {
                    DispatchQueue.main.async {
                        if !loginVM.isJoinError && password == confirmPassword && isEmailValid {
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
    // 이메일 유효성 검사
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    let loginVM = LoginViewModel()
    EmailSignUpView().environmentObject(loginVM)
}
