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
    @State private var invite_code: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                Text("멤버 초대 코드").font(.title).fontWeight(.bold).padding()
                Text("구성원들을 초대해 주세요!").padding()
                Text(invite_code)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray.opacity(0.4))
                    .cornerRadius(15)
                    .padding(.horizontal)
                
                    
            }.padding(.bottom, 300)
//            .onAppear {
//                invitecodeVM.fetchInviteCode { code in
//                    self.invite_code = code
//                }
//            }
            
            
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
}

#Preview {
    let invite = InviteCodeViewModel()
    let kakaoshare = KakaoShareViewModel()
    InviteMemberView().environmentObject(invite).environmentObject(kakaoshare)
}
