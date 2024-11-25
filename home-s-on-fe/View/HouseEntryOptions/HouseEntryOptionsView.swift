//
//  HouseEntryOptionsView.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/24/24.
//

import SwiftUI

struct HouseEntryOptionsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // 제목
                VStack(spacing: 8) {
                    Text("누구누구 님,")
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
                    Button(action: {
                        // 멤버 초대 액션
                        print("멤버 초대 버튼 클릭")
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 30))
                                .padding(.horizontal)
                                
                            VStack(alignment: .leading) {
                                Text("멤버초대")
                                    .fontWeight(.bold)
                                Text("방에 참여할 멤버 초대하기")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                        .background(Color(red: 175/255, green: 200/255, blue: 250/255))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // 집 입장하기 액션
                        print("집 입장하기 버튼 클릭")
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 30))
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading) {
                                Text("집 입장하기")
                                    .fontWeight(.bold)
                                
                                Text("만들어진 참여코드로 입장하기")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                        .background(Color(red: 87/255, green: 138/255, blue: 243/255))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 하단 텍스트
                Text("혼자 사용할래요!")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        print("혼자 사용하기 클릭")
                    }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("방 입장하기", displayMode: .inline)
        }
    }
}

#Preview {
    HouseEntryOptionsView()
}
