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
    let photo: String?
    let socialLoginType: String

    enum CodingKeys: String, CodingKey {
        case id, email, nickname, photo
        case socialLoginType = "social_login_type"
    }
}

struct UserHouse: Codable {
    let houseId: Int
    let userId:Int
    let isOwner:Bool
    
    enum CodingKeys: String, CodingKey {
        case houseId = "house_id"
        case userId = "user_id"
        case isOwner = "is_owner"
    }
    
}
