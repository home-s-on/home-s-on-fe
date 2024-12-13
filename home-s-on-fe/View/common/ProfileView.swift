//
//  ProfileView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/13/24.

import SwiftUI
import Kingfisher

struct ProfileView: View {
    let nickname: String
    let photo: String
    
    var body: some View {
        HStack(spacing: 12) {
            let photoURL = URL(string: "\(APIEndpoints.blobURL)/\(photo)")
            KFImage(photoURL)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .background(Color.clear)
                .clipShape(Circle())
            
            Text(nickname)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProfileView(nickname: "홍길동", photo: "default_profile.jpg")
}
