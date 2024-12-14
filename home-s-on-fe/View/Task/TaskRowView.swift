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
    @EnvironmentObject var triggerVM: TriggerViewModel
    @EnvironmentObject var getMemberVM: GetMembersInHouseViewModel
    @StateObject private var completeViewModel = TaskCompleteViewModel()
    @State private var showEditTask = false
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
    @State private var nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""
    
    private var isAssignee: Bool {
        appState.selectedTab == 1 && (task.assignees?.contains(where: { $0.id == userId }) ?? false)
    }
    
    private var coAssigneesCount: Int {
        (task.assignees?.filter { $0.id != userId }.count) ?? 0
    }
    
    var body: some View {
        Button(action: {
            showEditTask = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(task.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(task.complete ? .gray : .black)
                    Spacer()
                    if task.userId == userId {
                        Image(systemName: "pencil.and.scribble")
                            .foregroundColor(.mainColor)
                            .font(.system(size: 16))
                    }
                }
                
                HStack {
                    if let memo = task.memo {
                        Text(memo)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    if isAssignee {
                        Button(action: { completeTask() }) {
                            Image(systemName: task.complete ? "checkmark.square.fill" : "square")
                                .foregroundColor(task.complete ? .mainColor : .gray)
                                .font(.system(size: 20))
                        }
                        .padding(.top, 4)
                    }
                }
                
                HStack {
                    if let houseRoom = task.houseRoom {
                        Text(houseRoom.room_name)
                            .font(.system(size: 12))
                            .foregroundColor(Color.mainColor.opacity(0.8))
                    }
                    //반복
                    if let repeatDays = task.repeatDay, !repeatDays.isEmpty {
                        Text(task.repeatDay?.map { ["일", "월", "화", "수", "목", "금", "토"][$0] }.joined(separator: ", ") ?? "")
                               .font(.system(size: 12))
                               .foregroundColor(.blue)
                               .padding(.horizontal, 4)
                               .background(Color.blue.opacity(0.2))
                               .cornerRadius(4)
                       }
                    Spacer()
                    
                    // 모든 할 일 화면 - 모든 담당자 표시
                    if appState.selectedTab == 0, let assignees = task.assignees, !assignees.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.mainColor)
                            Text(assignees.map { $0.nickname }.joined(separator: ", "))
                                .font(.system(size: 12))
                                .foregroundColor(Color.mainColor.opacity(0.6))
                        }
                    } else if appState.selectedTab == 1 && coAssigneesCount > 0 {
                        // 나의 할일 탭에서는 추가 담당자 수만 표시
                        Text("외 \(coAssigneesCount)명")
                            .font(.system(size: 12))
                            .foregroundColor(Color.mainColor.opacity(0.8))
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
        
        // 먼저 하우스 멤버 정보를 가져옵니다.
        getMemberVM.getMembersInHouse()
        
        // 멤버 정보 로딩 완료를 기다립니다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let memberIds = getMemberVM.houseMembers.map { $0.userId }
            triggerVM.sendPushNotification(
                assigneeId: memberIds,
                title: "",
                subtitle: "\(nickname)님이 할 일을 완료했습니다.",
                body: task.title
            )
        }
    }
}
