//
//  EntryOptionButton.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/24/24.
//

import SwiftUI

struct EntryOptionButton:View {
    var body: some View {
        Button(action: {
            // 멤버 초대 액션
            print("멤버 초대 버튼 클릭")
        }) {
            HStack {
                Image(systemName: "envelope")
                    .font(.system(size: 30))
                    .padding(.horizontal)
                    
                
                VStack (alignment: .leading) {
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
    }
}

#Preview {
    EntryOptionButton()
}
