//
//  House.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/22/24.

import Foundation


struct House: Codable {
    let houseId: Int
    let nickname: String
    let inviteCode: String

    enum CodingKeys: String, CodingKey {
        case houseId
        case nickname
        case inviteCode
    }

struct InviteCode: Codable {
    let status: String
    let inviteCode: String
}
