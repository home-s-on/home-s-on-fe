//
//  User.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/18/24.
//

import Foundation

// 회원가입 성공 응답을 위한 빈 구조체
struct SignUpData: Codable {}

struct ApiResponse<T: Codable>: Codable {
    let status: String
    let message: String?
    let data: T?
}

struct EmailLoginData: Codable {
    let user: User
    let token: String
}

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let nickname: String?
    let profileImgUrl: String?
    let socialLoginType: String

    enum CodingKeys: String, CodingKey {
        case id, email, nickname
        case profileImgUrl = "profile_img_url"
        case socialLoginType = "social_login_type"
    }
}
