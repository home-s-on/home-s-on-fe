//
//  HouseMember.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/2/24.
//

import SwiftUI

struct HouseMember: Codable, Identifiable {
    let id = UUID()
    let userId: Int
    let nickname: String
    let isOwner: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId
        case nickname
        case isOwner = "is_owner"
    }
}

struct HouseMemberResponse: Codable {
    let status: String
    let data: [HouseMember]
}
