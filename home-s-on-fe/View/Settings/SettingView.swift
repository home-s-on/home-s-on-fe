//
//  SettingView.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/28/24.
//

import SwiftUI

struct SettingView: View {
    @State private var isShowInviteCode = false
    @State private var isShowPastTasks = false
    var body: some View {
        NavigationStack{
            VStack (spacing: 40){
                
                WideImageButton(icon: "", title: "멤버 확인하기", backgroundColor: .white, borderColer: .gray, textColor: .black) {
                    
                }
                WideImageButton(icon: "", title: "지난 할 일", backgroundColor: .white, borderColer: .gray, textColor: .black) {
                    isShowPastTasks = true
                    
                }
                WideImageButton(icon: "", title: "초대 코드", backgroundColor: .white, borderColer: .gray, textColor: .black) {
                    isShowInviteCode = true
                }
                .padding(.bottom, 300)
                Text("탈퇴할래요!")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        print("혼자 사용하기 클릭")
                        
                    }
                
            }
            .navigationDestination(isPresented: $isShowInviteCode) {
                InviteMemberView(isFromSetting: true)
            }
            .navigationDestination(isPresented: $isShowPastTasks) {
                PastTaskListView()
            }
        }
    }
}

#Preview {
    SettingView()
}
