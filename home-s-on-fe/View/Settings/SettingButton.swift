//
//  WideImageButton.swift
//  Yangpa-Market_SU1
//
//  Created by 정송희 on 11/15/24.
//

import SwiftUI

struct ButtonStyle {
    var backgroundColor: Color = .white
    var borderColer: Color = .clear
    var textColor: Color = .black
    var textFont: Font = .subheadline
    var isButtonShadowVisible = false
}

struct SettingButton: View {
    var icon: String
    var title: String
    var style: ButtonStyle = ButtonStyle()
    var isHidden = false
    var action: () -> Void
    var body: some View {
        
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .foregroundStyle(style.textColor)
            Text(title)
                .font(style.textFont)
                .foregroundStyle(style.textColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(style.borderColer, lineWidth: 2)
        ).padding(.horizontal)
            .opacity(isHidden ? 0 : 1 )
            .shadow(color: style.isButtonShadowVisible ? Color.black.opacity(0.1) : .clear,
                    radius: style.isButtonShadowVisible ? 5 : 0,
                    x: 0,
                    y: style.isButtonShadowVisible ? 2 : 0)
        
        
    }
}

#Preview {
    
    SettingButton(icon: "", title: "멤버 확인하기", style: ButtonStyle(isButtonShadowVisible: true)) {}
    SettingButton(icon: "", title: "지난 할일", style: ButtonStyle(backgroundColor: .cyan, borderColer: .white, textColor: .white, textFont: .caption, isButtonShadowVisible: true)) {}
}

