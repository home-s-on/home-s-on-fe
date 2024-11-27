//
//  InviteMemberView.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/24/24.
//

import SwiftUI

struct InviteMemberView: View {
    @EnvironmentObject var invitecodeVM: InviteCodeViewModel
    @EnvironmentObject var kakaoshareVM: KakaoShareViewModel
    @State private var inviteCode: String = UserDefaults.standard.string(forKey: "inviteCode") ?? ""
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("초대 코드를 입력해 주세요").font(.title3).fontWeight(.bold).padding()
                CustomTextField(icon: "", placeholder: "", text: $inviteCode)
            }
            }.padding(.horizontal)
            .padding(.bottom, 300)
            
            
            VStack{
                WideImageButton(icon: "", title: "집 입장하기", backgroundColor: .blue) {
                    print("집 입장")
                }
                WideImageButton(icon: "", title: "초대 코드 보내기", backgroundColor: .blue)
                {
                    print("초대 코드 보내기")
                    kakaoshareVM.sendKakaoMessage(text: invitecodeVM.invitecode)
                }
            }
            
        }
    }


#Preview {
    let invite = InviteCodeViewModel()
    let kakaoshare = KakaoShareViewModel()
    InviteMemberView().environmentObject(invite).environmentObject(kakaoshare)
}
