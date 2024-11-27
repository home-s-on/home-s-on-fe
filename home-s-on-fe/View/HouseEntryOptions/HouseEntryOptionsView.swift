//
//  HouseEntryOptionsView.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/24/24.
//

import SwiftUI

struct HouseEntryOptionsView: View {
    @AppStorage("nickname") var nickname: String = ""
    @State private var navigationPath = NavigationPath()
        
        var body: some View {
            NavigationStack(path: $navigationPath) {
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
                                navigationPath.append("InviteMember")
                            },
                            imageName: "envelope",
                            title: "멤버초대",
                            subtitle: "방에 참여할 멤버 초대하기",
                            backgroundColor: Color(red: 175/255, green: 200/255, blue: 250/255)
                        )
                        
                        EntryOptionButton(
                            action: {
                                print("집 입장하기 버튼 클릭")
                            },
                            imageName: "house.fill",
                            title: "집 입장하기",
                            subtitle: "만들어진 참여코드로 입장하기",
                            backgroundColor: Color(red: 87/255, green: 138/255, blue: 243/255))
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Text("혼자 사용할래요!")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            print("혼자 사용하기 클릭")
                        }
                    
                    Spacer()
                }
                .padding()
                .navigationDestination(for: String.self) { destination in
                    switch destination {
                    case "InviteMember":
                        InviteMemberView()
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }


#Preview {
    HouseEntryOptionsView()
}
