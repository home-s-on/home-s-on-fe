import Foundation

struct Task: Identifiable, Codable {
    let id: Int
    let houseId: Int
    let houseRoomId: Int
    let userId: Int
    let title: String
    let memo: String?
    let alarm: String?
    let assigneeId: [Int]
    let dueDate: String?
    let complete: Bool
    let createdAt: String
    let updatedAt: String
    let houseRoom: HouseRoom?
    
    enum CodingKeys: String, CodingKey {
        case id
        case houseId = "house_id"
        case houseRoomId = "house_room_id"
        case userId = "user_id"
        case title
        case memo
        case alarm
        case assigneeId = "assignee_id"
        case dueDate = "due_date"
        case complete
        case createdAt
        case updatedAt
        case houseRoom = "HouseRoom"
    }
}

struct HouseRoom: Codable {
    let id: Int
    let roomName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomName = "room_name"
    }
}

struct TaskResponse: Codable {
    let success: Bool
    let data: [Task]
}
