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
    let house: MemberHouse?

    enum CodingKeys: String, CodingKey {
        case id, updatedAt, createdAt
        case houseId = "house_id"
        case membersId = "members_id"
        case house = "House"
    }
}

struct HouseInMember: Codable,Hashable {
    let userId: Int
    let nickname: String
    let isOwner: Bool
}


struct MemberHouse: Codable {
    let inviteCode: String

        enum CodingKeys: String, CodingKey {
            case inviteCode = "invite_code"
        }
    }

