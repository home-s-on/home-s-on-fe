//
//  WideImageButton.swift
//  Yangpa-Market_SU1
//
//  Created by 정송희 on 11/15/24.
//

import SwiftUI

struct WideImageButton: View {
    var icon:String
    var title:String
    var backgroundColor:Color
    var borderColer:Color = .clear // 버튼 외곽 색, 기본값 안 보이게 clear로 설정
    var textColor:Color = .white
    var action:() -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .foregroundStyle(textColor)
            Text(title)
                .font(.headline)
                .foregroundStyle(textColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColer, lineWidth: 2)
        ).padding(.horizontal)
    }
}

#Preview {
    WideImageButton(icon: "person.fill", title: "로그인", backgroundColor: .orange){}
    WideImageButton(icon: "person.fill", title: "로그인",backgroundColor: .orange, borderColer:.gray, textColor: .black){}
}
