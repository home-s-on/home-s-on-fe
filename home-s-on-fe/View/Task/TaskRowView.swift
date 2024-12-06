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
    @StateObject private var completeViewModel = TaskCompleteViewModel()
    @State private var showEditTask = false
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
    
    private var isAssignee: Bool {
        task.assignees?.contains(where: { $0.id == userId }) ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.complete ? .gray : .black)
                Spacer()
                
                // 편집 버튼
                if task.canEdit {
                    Button(action: {
                        showEditTask = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                }
            }
            HStack{
                if let memo = task.memo {
                    Text(memo)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // 완료 체크박스 (담당자만 볼 수 있음)
                if isAssignee {
                    HStack {
                        Spacer()
                        Button(action: { completeTask() }) {
                            Image(systemName: task.complete ? "checkmark.square.fill" : "square")
                                .foregroundColor(task.complete ? .blue : .gray)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            HStack {
                if let houseRoom = task.houseRoom {
                    Text(houseRoom.room_name)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                Spacer()
                
                // 담당자 정보
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
        .background(task.complete ? Color.gray.opacity(0.1) : Color.white)
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
        .alert(completeViewModel.message, isPresented: $completeViewModel.showSuccessAlert) {
            Button("확인") {
                completeViewModel.showSuccessAlert = false
            }
        }
        .alert("오류", isPresented: $completeViewModel.isFetchError) {
            Button("확인") {
                completeViewModel.isFetchError = false
            }
        } message: {
            Text(completeViewModel.message)
        }
    }
    
    private func completeTask() {
        completeViewModel.toggleTaskComplete(taskId: task.id) {
            if appState.selectedTab == 0 {
                viewModel.fetchTasks(houseId: task.houseId)
            } else {
                viewModel.fetchMyTasks(userId: userId)
            }
        }
    }
}
