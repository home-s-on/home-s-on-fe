//
//  InviteMemberView.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/24/24.
//

import SwiftUI

struct InviteMemberView: View {
    @StateObject var joinMemberVM = JoinMemberViewModel()
    @StateObject var kakaoshareVM = KakaoShareViewModel()
    @State private var inviteCode: String = UserDefaults.standard.string(forKey: "inviteCode") ?? ""
    @State private var navigateToView = false
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    var isFromSetting = false
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("멤버 초대 코드").font(.title).fontWeight(.bold).padding()
                    VStack(alignment: .leading) {
                        Text("구성원들을 초대해주세요!")
                            .font(.headline)
                        CustomTextField(icon: "", placeholder: "", text: $inviteCode)
                    }.padding(.horizontal)
                }
            }.padding(.horizontal)
                .padding(.bottom, 300)
            
            
            VStack{
                if !isFromSetting {
                    WideImageButton(icon: "", title: "집 입장하기", backgroundColor: .blue) {
                        print("집 입장")
                        joinMemberVM.joinMember(houseId: houseId)
                        navigateToView = true
                    }
                }
                WideImageButton(icon: "", title: "초대 코드 보내기", backgroundColor: .blue) {
                    print("초대 코드 보내기")
                    kakaoshareVM.sendKakaoMessage(text: inviteCode)
                }
            }

            NavigationLink(destination: MainView(), isActive: $navigateToView) {
                EmptyView()
            }
            
            
        }
    }
}


#Preview {
    
    let kakaoshare = KakaoShareViewModel()
    InviteMemberView().environmentObject(kakaoshare)
}
