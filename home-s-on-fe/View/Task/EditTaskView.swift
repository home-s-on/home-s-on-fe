//
//  EditTaskView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/4/24.
//

import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    @StateObject private var completeViewModel = TaskCompleteViewModel()
    @Binding var isPresented: Bool
    var task: Task
    
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
    @State private var title: String
    @State private var memo: String
    @State private var selectedRoom: HouseRoom?
    @State private var dueDate: String
    @State private var isAlarmOn: Bool
    @State private var selectedAssignee: HouseInMember?
    
    init(task: Task, isPresented: Binding<Bool>, houseId: Int) {
        self.task = task
        self._isPresented = isPresented
        self.houseId = houseId
        
        _title = State(initialValue: task.title)
        _memo = State(initialValue: task.memo ?? "")
        _selectedRoom = State(initialValue: task.houseRoom)
        
        if let dueDate = task.dueDate {
            let formattedDate = Self.formatDate(dueDate)
            _dueDate = State(initialValue: formattedDate)
        } else {
            _dueDate = State(initialValue: "")
        }
        
        _isAlarmOn = State(initialValue: task.alarm != nil)
        
        if let assignee = task.assignees?.first {
            _selectedAssignee = State(initialValue: HouseInMember(
                userId: assignee.id,
                nickname: assignee.nickname,
                isOwner: false
            ))
        } else {
            _selectedAssignee = State(initialValue: nil)
        }
    }
    
    private static func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        return dateString
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && selectedRoom != nil && selectedAssignee != nil && !dueDate.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("할일 제목", text: $title)
                    
                    TextField("메모(선택사항)", text: $memo)
                    
                    NavigationLink(destination: RoomSelectionView(selectedRoom: $selectedRoom)) {
                        HStack {
                            Text("구역 선택")
                            Spacer()
                            if let room = selectedRoom {
                                Text(room.room_name).foregroundColor(.gray)
                            }
                        }
                    }
                    
                    NavigationLink {
                        DateSelectionView(dueDate: $dueDate)
                    } label: {
                        HStack {
                            Text("날짜")
                            Spacer()
                            Text(dueDate).foregroundColor(.gray)
                        }
                    }
                    
                    Toggle("알람", isOn: $isAlarmOn)
                    
                    NavigationLink(destination: AssigneeSelectionView(selectedAssignee: $selectedAssignee).environmentObject(GetMembersInHouseViewModel())) {
                        HStack {
                            Text("담당자 지정")
                            Spacer()
                            if let assignee = selectedAssignee {
                                Text(assignee.nickname)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                Button(action: { completeTask() }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(task.complete ? "할일 완료 취소" : "할일 완료")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(task.complete ? .gray : .blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("할일 수정")
            .navigationBarItems(
                leading: Button("취소") {
                    isPresented = false
                },
                trailing: Button("저장") {
                    saveTask()
                }
                .disabled(!isFormValid)
            )
        }
        //할일완료alter
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
    
    private func saveTask() {
        guard let roomId = selectedRoom?.id, let assignee = selectedAssignee else {
            viewModel.message = "필수 정보를 모두 입력해주세요."
            viewModel.isFetchError = true
            return
        }
        
        viewModel.onTaskEdited = {
            if appState.selectedTab == 0 {
                self.viewModel.fetchTasks(houseId: self.houseId)
            } else if appState.selectedTab == 1 {
                self.viewModel.isLoading = false
                self.viewModel.fetchMyTasks(userId: self.userId)
            }
        }
        
        viewModel.editTask(
            taskId: task.id,
            houseRoomId: roomId,
            title: title,
            assigneeId: [assignee.userId],
            memo: memo.isEmpty ? nil : memo,
            alarm: isAlarmOn ? "on" : nil,
            dueDate: dueDate.isEmpty ? nil : dueDate
        )
        isPresented = false
    }
    
    private func completeTask() {
        completeViewModel.toggleTaskComplete(taskId: task.id) {
            if appState.selectedTab == 0 {
                viewModel.fetchTasks(houseId: self.houseId)
            } else {
                viewModel.fetchMyTasks(userId: self.userId)
            }
            isPresented = false
        }
    }
}

#Preview {
    EditTaskView(
        task: Task(
            id: 1,
            houseId: 1,
            houseRoomId: 1,
            userId: 1,
            title: "테스트 할일",
            memo: "테스트 메모",
            alarm: false,  // String이 아닌 Bool로 변경
            repeatDay: [],  // nil 대신 빈 배열
            assigneeId: [1],
            dueDate: "2024-12-06T00:00:00.000Z",
            complete: false,
            createdAt: "2024-12-06T00:00:00.000Z",
            updatedAt: "2024-12-06T00:00:00.000Z",
            houseRoom: HouseRoom(
                id: 1,
                house_id: 1,  // house_id 파라미터 추가
                room_name: "거실"
            ),
            assignees: [
                TaskUser(
                    id: 1,
                    nickname: "테스트 유저"
                )
            ]
        ),
        isPresented: .constant(true),
        houseId: 1
    )
    .environmentObject(TaskViewModel())
    .environmentObject(SelectedTabViewModel())
}
