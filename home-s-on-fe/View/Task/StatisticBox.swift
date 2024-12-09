//
//  StatisticBox.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/10/24.
//

import SwiftUI

struct StatisticBox: View {
    let title: String
    let value: String
    let color: Color
    
    init(title: String, value: String, color: Color = .mainColor) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

#Preview {
    StatisticBox(title: "완료", value: "5", color: .mainColor)
}
