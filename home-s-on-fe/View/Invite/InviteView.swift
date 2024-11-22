//
//  InviteView.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/21/24.
//

import SwiftUI

struct InviteView: View {
    @EnvironmentObject var invitecodeVM: InviteCodeViewModel
    @EnvironmentObject var kakaoshareVM: KakaoShareViewModel
    var body: some View {
        
        Button(action: {
            invitecodeVM.fetchInviteCode { code in
                kakaoshareVM.sendKakaoMessage(text: code)
            }
           
            
            
        }) {
            Text("Share Invite Code")
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    let invite = InviteCodeViewModel()
    let kakaoshare = KakaoShareViewModel()
    InviteView().environmentObject(invite).environmentObject(kakaoshare)
}
