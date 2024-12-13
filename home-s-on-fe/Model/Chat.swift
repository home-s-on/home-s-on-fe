//
//  Chat.swift
//  home-s-on-fe
//
//  Created by 정송희 on 12/10/24.
//

import Foundation


struct SendChat: Codable {
    let userMessage: String
    let assistantResponse: String
}

struct GetChat: Codable {
    let existingChat: [Chat]
}

struct Chat: Codable, Identifiable, Equatable {
    let id: Int
    let userId: Int
    let userMessage: String
    let assistantResponse: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userMessage = "user_message"
        case assistantResponse = "assistant_response"
    }
}

struct MotivationChat: Codable {
    let status: String
    let message: String
}


