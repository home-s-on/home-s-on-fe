//
//  EditTaskView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/4/24.
//
import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var membersViewModel: GetMembersInHouseViewModel
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
    @State private var endDate: String
    @State private var isAlarmOn: Bool
    @State private var selectedAssignees: Set<HouseInMember> = []
    @State private var showDeleteConfirmation = false
    @State private var selectedDays: Set<Int> = []
    
    let daysOfWeek = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]

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
        
        if let endDate = task.end_date {
                   let formattedEndDate = Self.formatDate(endDate)
                   _endDate = State(initialValue: formattedEndDate)
               } else {
                   _endDate = State(initialValue: "")
               }
        
        _isAlarmOn = State(initialValue: task.alarm != nil)
        
        //담당자초기화
        var initialAssignees: Set<HouseInMember> = []
        if let assignees = task.assignees {
            for assignee in assignees {
                initialAssignees.insert(HouseInMember(
                    userId: assignee.id,
                    nickname: assignee.nickname,
                    isOwner: false
                ))
            }
        }
        _selectedAssignees = State(initialValue: initialAssignees)
        
        //반복요일초기화
        if let repeatDays = task.repeatDay {
            _selectedDays = State(initialValue: Set(repeatDays))
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
        !title.isEmpty && selectedRoom != nil && !selectedAssignees.isEmpty && !dueDate.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                if task.canEdit {
                    TextField("할일 제목", text: $title)
                } else {
                    Text(title).foregroundColor(.primary)
                }
                
                if task.canEdit {
                    TextField("메모(선택사항)", text: $memo)
                } else if !memo.isEmpty {
                    Text(memo).foregroundColor(.gray)
                }

                if task.canEdit {
                    NavigationLink(destination: RoomSelectionView(selectedRoom: $selectedRoom)) {
                        HStack {
                            Text("구역 선택")
                            Spacer()
                            if let room = selectedRoom {
                                Text(room.room_name).foregroundColor(.gray)
                            }
                        }
                    }
                } else if let room = selectedRoom {
                    HStack {
                        Text("구역")
                        Spacer()
                        Text(room.room_name).foregroundColor(.gray)
                    }
                }
                if task.canEdit {
                    NavigationLink(destination: RepeatSelectionView(selectedDays: $selectedDays)) {
                        HStack {
                            Text("반복")
                            Spacer()
                            if !selectedDays.isEmpty {
                                Text(selectedDays.sorted().map { daysOfWeek[$0] }.joined(separator: ", "))
                                    .foregroundColor(.gray)
                            } else {
                                Text("선택되지 않음").foregroundColor(.gray)
                            }
                        }
                    }
                    
                    NavigationLink {
                        DateSelectionView(dueDate: $dueDate)
                    } label: {
                        HStack {
                            Text("마감 날짜")
                            Spacer()
                            Text(dueDate).foregroundColor(.gray)
                        }
                    }
                    
                    if !selectedDays.isEmpty {
                        NavigationLink {
                            DateSelectionView(dueDate: $endDate)
                        } label: {
                            HStack {
                                Text("반복 종료 날짜")
                                Spacer()
                                Text(endDate).foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    if !selectedDays.isEmpty {
                        HStack {
                            Text("반복")
                            Spacer()
                            Text(selectedDays.sorted().map { daysOfWeek[$0] }.joined(separator: ", "))
                                .foregroundColor(.gray)
                        }
                    }
                    HStack {
                        Text("마감 날짜")
                        Spacer()
                        Text(dueDate).foregroundColor(.gray)
                    }
                    if !selectedDays.isEmpty {
                        HStack {
                            Text("반복 종료 날짜")
                            Spacer()
                            Text(endDate).foregroundColor(.gray)
                        }
                    }
                }

                if task.canEdit {
                    Toggle("알람", isOn: $isAlarmOn)
                } else {
                    HStack {
                        Text("알람")
                        Spacer()
                        Text(isAlarmOn ? "켜짐" : "꺼짐").foregroundColor(.gray)
                    }
                }

                if task.canEdit {
                    NavigationLink(destination: AssigneeSelectionView(selectedAssignees: $selectedAssignees).environmentObject(membersViewModel)) {
                        HStack {
                            Text("담당자 지정")
                            Spacer()
                            if !selectedAssignees.isEmpty {
                                Text(selectedAssignees.map { $0.nickname }.joined(separator: ", "))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("담당자")
                        Spacer()
                        Text(selectedAssignees.map { $0.nickname }.joined(separator: ", "))
                            .foregroundColor(.gray)
                    }
                }

                if task.canEdit {
                    Section {
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack {
                                Spacer()
                                Text("할일 삭제").foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(task.canEdit ? "할일 수정" : "할일 상세")
            .navigationBarItems(
                leading: Button("닫기") { isPresented = false },
                trailing: task.canEdit ? Button("저장") { saveTask() }.disabled(!isFormValid) : nil
            )
            .alert("할일 삭제", isPresented: $showDeleteConfirmation) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) { deleteTask() }
            } message: {
                Text("정말 삭제하시겠습니까?")
            }
            .alert(completeViewModel.message, isPresented: $completeViewModel.showSuccessAlert) {
                Button("확인") {
                    completeViewModel.showSuccessAlert = false
                    if !completeViewModel.isFetchError {
                        isPresented = false
                    }
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
    }
    
    private func saveTask() {
        guard let roomId = selectedRoom?.id, !selectedAssignees.isEmpty else {
            viewModel.message = "필수 정보를 모두 입력해주세요."
            viewModel.isFetchError = true
            return
        }

        viewModel.editTask(
            taskId: task.id,
            houseRoomId: roomId,
            title: title,
            assigneeId: selectedAssignees.map { $0.userId },
            memo: memo.isEmpty ? nil : memo,
            alarm: isAlarmOn,
            dueDate: dueDate.isEmpty ? nil : dueDate,
            repeatDay: selectedDays.isEmpty ? nil : Array(selectedDays),
            endDate: selectedDays.isEmpty ? nil : endDate
        )

        viewModel.onTaskEdited = { [self] in
            if appState.selectedTab == 0 {
                self.viewModel.fetchTasks(houseId: self.houseId)
            } else if appState.selectedTab == 1 {
                self.viewModel.isLoading = false
                self.viewModel.fetchMyTasks(userId: self.userId)
            }
            isPresented = false
        }
    }

    private func deleteTask() {
        completeViewModel.deleteTask(taskId: task.id) { [self] in
            if !completeViewModel.isFetchError {
                if appState.selectedTab == 0 {
                    viewModel.fetchTasks(houseId: houseId)
                } else {
                    viewModel.fetchMyTasks(userId: userId)
                }
                    isPresented = false

            }
        }
    }
}
