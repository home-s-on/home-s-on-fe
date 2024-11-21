//
//  ProfileEditView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/21/24.
//

import SwiftUI

struct ProfileEditView:View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var text: String = ""
    @State var nickname:String = ""
    @State var img_url:String = ""
    var body: some View {
        VStack {
            ZStack {
                RoundImage(image: UIImage(named: "round-profile")!, width: .constant(180.0), height: .constant(180.0))
                
                RoundImage(image: UIImage(systemName: "pencil.circle")!, width: .constant(50.0), height: .constant(50.0))
                                    .background(Circle().fill(Color(red: 33/255, green: 174/255, blue: 225/255)).frame(width: 55, height: 55))
                                    .offset(x: 60, y: 60)
            }
            
            
            VStack(alignment: .leading) {
                Text("별명으로 사용할 이름을 입력하세요")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 15, weight: .regular))
                    .padding(.top)
                    .padding(.horizontal)
                    
                
                CustomTextField(icon: "", placeholder: "nickname", text: $text)
            }.padding(.bottom, 260)
            
            
            
            WideImageButton(icon: "", title: "완료", backgroundColor: .blue){
                profileVM.profileEdit(nickname: nickname, img_url: img_url)
            }

            
        }
        .alert("프로필 설정 확인", isPresented: $profileVM.isProfileShowing) {
            Button("확인") {
                profileVM.isProfileShowing = false
            }
        } message: {
            Text(profileVM.message)
        }
    }
}

#Preview {
    let profileVM = ProfileViewModel()
    ProfileEditView().environmentObject(profileVM)
}
