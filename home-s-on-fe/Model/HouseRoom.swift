//
//  HouseRoom.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/27/24.
//

import Foundation

struct HouseRoom: Codable, Identifiable {
    let id: Int
    let house_id: Int?
    let room_name: String
}

struct RoomResponse: Codable {
    let success: Bool
    let data: [HouseRoom]
}

struct AddRoomResponse: Codable {
    let success: Bool
    let data: HouseRoom
}

struct ErrorResponse: Codable {
    let success: Bool
    let error: String
}

struct SingleRoomResponse: Codable {
    let success: Bool
    let data: HouseRoom
}
