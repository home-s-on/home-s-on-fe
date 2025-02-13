//
//  HouseEntryOptionsView.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/24/24.
//

import SwiftUI

struct HouseEntryOptionsView: View {
    @AppStorage("nickname") var nickname: String = ""
    @State private var showAlert = false
    @State private var navigateToNewView = false
    @State private var showInviteMemberView = false
    @State private var showEnterInviteCodeView = false
    @StateObject var joinToHouseVM = JoinToHouseViewModel()
    @StateObject var joinMemberVM = JoinMemberViewModel()
    @StateObject var getHouseIdVM = GetHouseIdViewModel()
    @AppStorage("houseId") var houseId: Int?

        var body: some View {
            NavigationStack {
                VStack(spacing: 20) {
                    Spacer()

                    
                    // 제목
                    VStack(spacing: 8) {
                        Text("\(nickname) 님,")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("함께 할 멤버를 초대하거나\n집에 입장해 보세요")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    

                    VStack(spacing: 16) {
                        EntryOptionButton(
                            action: {
                                showInviteMemberView = true
                            },
                            imageName: "envelope",
                            title: "멤버초대",
                            subtitle: "방에 참여할 멤버 초대하기",
                            backgroundColor: Color(red: 175/255, green: 200/255, blue: 250/255)
                        )
                        
                        EntryOptionButton(
                            action: {
                                showEnterInviteCodeView = true
                            },
                            imageName: "house.fill",
                            title: "집 입장하기",
                            subtitle: "만들어진 참여코드로 입장하기",
                            backgroundColor: Color(red: 87/255, green: 138/255, blue: 243/255))
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
              VStack {
                    Text("혼자 사용할래요!")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            print("혼자 사용하기 클릭")
                            showAlert = true
                        }
                    
              }
               .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("혼자 사용하기"),
                        message: Text("멤버 없이 앱 사용하시겠습니까?\n나중에 멤버를 추가하려면 \n설정 창에서 연결 할 수 있습니다."),
                        primaryButton: .cancel({
                            Text("취소")
                        }), secondaryButton: .default(Text("확인"), action: {
                            print("확인")
                            if let id = houseId {
                                joinMemberVM.joinMember(houseId: id)
                            } else {
                                print("houseId 에러로 인한 집 입장 실패")
                            }
                            navigateToNewView = true
                        }))
                }
                    
                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $showInviteMemberView) {
                    InviteMemberView()
                        .environmentObject(joinMemberVM)
                    
                }
                .navigationDestination(isPresented: $showEnterInviteCodeView) {
                    EnterInviteCodeView()
                        .environmentObject(joinToHouseVM)
                        .environmentObject(getHouseIdVM)
                        .environmentObject(joinMemberVM)
                }
                .navigationDestination(isPresented: $navigateToNewView) {
                    MainView()
                        .environmentObject(joinMemberVM)
                }

            }
        }
    }


#Preview {
    let joinToHouseVM = JoinToHouseViewModel()
    HouseEntryOptionsView().environmentObject(joinToHouseVM)
}
