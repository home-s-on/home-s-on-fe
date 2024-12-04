//
//  Member.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 12/1/24.
//

import Foundation

struct Member: Codable, Identifiable {
    let id: Int
    let houseId: Int
    let membersId: [Int]
    let updatedAt: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, updatedAt, createdAt
        case houseId = "house_id"
        case membersId = "members_id"
    }
}

struct HouseInMember: Codable {
    let userId: Int
    let nickname: String
    let isOwner: Bool
}
