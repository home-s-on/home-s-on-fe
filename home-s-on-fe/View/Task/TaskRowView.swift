//
//  TaskRowView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/22/24.
//
import SwiftUI


struct TaskRowView: View {
    let task: Task
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    @State private var showEditTask = false
    var canEdit: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                // 편집 버튼 추가
                if canEdit {  // canEdit이 true일 때만 버튼 표시
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
            
            HStack {
                if let houseRoom = task.houseRoom {
                    Text(houseRoom.room_name)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                Spacer()
                // 담당자 정보 추가
                if let assignees = task.assignees, !assignees.isEmpty {
                    HStack(spacing: 4) {
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
        .sheet(isPresented: $showEditTask) {
            EditTaskView(
                task: task,
                isPresented: $showEditTask,
                houseId: task.houseId
            )
            .environmentObject(viewModel)
            .environmentObject(appState)
        }
    }
    
    
}

