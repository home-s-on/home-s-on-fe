//
//  TaskRowView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/22/24.
//
import SwiftUI


struct TaskRowView: View {
    let task: Task
    let showAssignee: Bool
    @StateObject private var viewModel = TaskViewModel()
    @State private var showEditTask = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                // 편집 버튼 추가
                if task.canEdit {
                    Button(action: {
                        showEditTask = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    
                }
                //완료 체크박스
                if task.complete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                                 }
                    }
            
            if let memo = task.memo {
                Text(memo)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            HStack{
                if let houseRoom = task.houseRoom {
                    Text(houseRoom.room_name)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                Spacer()
                if showAssignee, let assignees = task.assignees {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                        Text(assignees.map { $0.nickname }.joined(separator: ", "))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                }
                
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        // 편집 화면 모달
        .sheet(isPresented: $showEditTask) {
            TaskEditView(
                viewModel: viewModel,
                task: task,
                isPresented: $showEditTask,
                houseId: task.houseId
            )
        }
    }
}
#Preview {
    let _ = UserDefaults.standard.set(1, forKey: "userId") 
    
    let sampleTask = Task(
        id: 1,
        houseId: 1,
        houseRoomId: 1,
        userId: 1,
        title: "방청소 하기",
        memo: "먼지 쌓여있음",
        alarm: "11:00:00",
        assigneeId: [1],
        dueDate: "2024-12-31",
        complete: true,
        createdAt: "2024-11-22",
        updatedAt: "2024-11-22",
        houseRoom: HouseRoom(id: 1,house_id: 1,room_name: "거실"),
        assignees: [
            TaskUser(
                id: 1,
                nickname: "Park"
            )
        ]
    )
    
    TaskRowView(task: sampleTask,showAssignee: true)
        .padding()
        .background(Color(.systemBackground))
}
