//
//  CoustomButton.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/19/24.
//

import SwiftUI

struct CustomActionButton: View {
    var text: String
    var textColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomActionButton(text: "Login", textColor: .white) {
            print("Login button tapped")
        }
        CustomActionButton(text: "Sign Up", textColor: .blue) {
            print("Sign Up button tapped")
        }
    }
    .padding()
}
