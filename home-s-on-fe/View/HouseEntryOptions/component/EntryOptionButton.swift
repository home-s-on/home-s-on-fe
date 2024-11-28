//
//  EntryOptionButton.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/24/24.
//

import SwiftUI

struct EntryOptionButton:View {
    var action: () -> Void
    var imageName: String
    var title: String
    var subtitle: String
    var backgroundColor: Color
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .font(.system(size: 30))
                    .padding(.horizontal)
                    
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.bold)
                    Text(subtitle)
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
            .background(backgroundColor)
            .cornerRadius(8)
        }
    }
}

#Preview {
    EntryOptionButton(action: {print("방 입장하기 넣기")}, imageName: "envelope", title: "멤버 초대", subtitle: "방에 참여할 멤버 초대하기", backgroundColor: Color(red: 175/255, green: 200/255, blue: 250/255))
}
