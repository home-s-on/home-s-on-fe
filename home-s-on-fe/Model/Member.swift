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
    let updatedAt: Data
    let createAt: Data

    enum CodingKeys: String, CodingKey {
        case id, updatedAt, createAt
        case houseId = "house_id"
        case membersId = "members_id"
    }
}
