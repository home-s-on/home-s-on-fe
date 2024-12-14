import Foundation

struct Task: Identifiable, Codable {
    let id: Int
    let houseId: Int
    let houseRoomId: Int
    let userId: Int
    let title: String
    let memo: String?
    let alarm: Bool
    let repeatDay: [Int]?
    let assigneeId: [Int]
    let dueDate: String?
    let complete: Bool
    let createdAt: String?
    let updatedAt: String?
    let houseRoom: HouseRoom?
    let assignees: [TaskUser]?
    //반복요일을 위한 필드
    let parentTaskId: Int?
    let isRecurring: Bool
    
    // 편집 권한 확인용
        var canEdit: Bool {
            return userId == UserDefaults.standard.integer(forKey: "userId")
        }
    
    enum CodingKeys: String, CodingKey {
        case id
        case houseId = "house_id"
        case houseRoomId = "house_room_id"
        case userId = "user_id"
        case title, memo, alarm
        case repeatDay = "repeat_day"
        case assigneeId = "assignee_id"
        case dueDate = "due_date"
        case complete
        case createdAt, updatedAt
        case houseRoom = "HouseRoom"
        case assignees
        case parentTaskId = "parent_task_id"
        case isRecurring = "is_recurring"
    }
}

struct TaskUser: Codable {
    let id: Int
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case id, nickname
    }
}

struct TaskResponse<T: Codable>: Codable {
    let success: Bool
    let data: [T]
    let message: String?
}

struct CompleteTaskResponse<T: Codable>: Codable {
    let success: Bool
    let data: TaskData
    let message: String
    
    struct TaskData: Codable {
        let completedTask: T
        let nextTask: T?
    }
}

struct AddTaskResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
}

struct EditTaskResponse: Codable {
    let success: Bool
    let data: Task
}

struct DeleteResponse: Codable {
    let success: Bool
    let message: String
}
