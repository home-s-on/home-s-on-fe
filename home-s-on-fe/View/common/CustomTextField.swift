//
//  LoginTextField.swift
//  Yangpa-Market_SU1
//
//  Created by 정송희 on 11/15/24.
//

import SwiftUI

struct CustomTextField: View {
    var icon:String
    var placeholder:String
    @Binding var text:String // 상위뷰에서 사용하기 때문에 binding
    var isSecured:Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.gray)
            if !isSecured {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none) // 첫문자 대문자 방지
                    .autocorrectionDisabled(true)
            }else {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
            }
        }.padding()
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.5), lineWidth: 1))
            .padding(.horizontal)
    }
}

#Preview {
    CustomTextField(icon: "person.fill", placeholder: "사용자 ID를 입력하시오.", text: .constant("song"))
    CustomTextField(icon: "lock.fill", placeholder: "사용자 비밀번호를 입력하시오.", text: .constant("1234"), isSecured: true)
}
