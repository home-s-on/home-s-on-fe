//
//  EnterInviteCodeView.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/25/24.
//

import SwiftUI

struct EnterInviteCodeView: View {
    @State private var code = ""
    var body: some View {
        VStack {
            
            VStack (alignment: .leading){
                Text("초대코드를 입력해주세요")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading)
               
                CustomTextField(icon: "", placeholder: "받은 초대 코드 입력", text: $code)
                    .padding(.horizontal)
                
            }.padding(.bottom, 400)
            
            
            WideImageButton(icon: "", title: "확인", backgroundColor: .blue) {
                print("초대 코드 입력")
            }
        }
    }
}

#Preview {
    EnterInviteCodeView()
}
