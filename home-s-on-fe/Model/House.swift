//
//  House.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 11/24/24.
//

import Foundation

struct House: Codable {
    let houseId: Int
    let nickname: String
    let inviteCode: String
    
    enum CodingKeys: String, CodingKey {
        case houseId = "houseId"
        case nickname
        case inviteCode = "inviteCode"
    }
}
