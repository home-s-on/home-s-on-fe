//
//  RoundImage.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/21/24.
//

import SwiftUI

struct RoundImage: View {
    let image: UIImage
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    var color: Color = .clear

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .overlay(Circle().fill(color).opacity(0.3))
            .frame(width: width, height: height)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24.0)
    }
}

#Preview {
    RoundImage(image: UIImage(named: "round-profile") ?? UIImage(), width: .constant(198.0), height: .constant(198.0), color: Color.gray)
}
