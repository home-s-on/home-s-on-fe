//
//  House.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/22/24.

import Foundation


struct House: Codable {
    let houseId: Int?
    let nickname: String
    let inviteCode: String
    
    enum CodingKeys: String, CodingKey {
        case houseId = "houseId"
        case nickname
        case inviteCode = "inviteCode"
    }
}

struct InviteCode: Codable {
    let status: String
    let inviteCode: String
}

struct HouseId : Codable {
    let id: Int
    let inviteCode: String
    
    enum CodingKeys: String, CodingKey {
            case id
            case inviteCode = "invite_code"
        }
}

struct HouseInfo: Codable {
    let houseId: Int
    let inviteCode: String

    enum CodingKeys: String, CodingKey {
        case houseId = "house_id"
        case inviteCode = "invite_code"
    }
}
