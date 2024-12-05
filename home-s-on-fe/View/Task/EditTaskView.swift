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
    @Binding var isPresented: Bool
    var task: Task
//    let houseId: Int
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")

    
    @State private var title: String
    @State private var memo: String
    @State private var selectedRoom: HouseRoom?
    @State private var dueDate: String
    @State private var isAlarmOn: Bool
    @State private var selectedAssignee: HouseInMember?
    
    // 초기화 시 기존 데이터로 상태 초기화
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
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 원본 날짜
            if let date = formatter.date(from: dateString) {
                formatter.dateFormat = "yyyy-MM-dd" // 출력할 날짜
                return formatter.string(from: date)
            }
            return dateString 
        }
    
    private var isFormValid: Bool {
        !title.isEmpty && selectedRoom != nil && selectedAssignee != nil && !dueDate.isEmpty
    }
    
    var body: some View {
        NavigationView {
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
        .alert("오류", isPresented: $viewModel.isFetchError) {
            Button("확인") {
                viewModel.isFetchError = false
            }
        } message: {
            Text(viewModel.message)
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
                // "할일 목록" 탭일 때
                self.viewModel.fetchTasks(houseId: self.houseId)
            } else if appState.selectedTab == 1 {
                // "나의 할일" 탭일 때
                self.viewModel.isLoading = false
                self.viewModel.fetchMyTasks(userId: self.userId)
            }

            print("edittask saveTask 끝")

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
}

#Preview {}
