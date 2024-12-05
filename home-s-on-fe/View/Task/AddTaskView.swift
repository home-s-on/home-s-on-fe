//
//  AddTaskView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/25/24.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var dueDate: String = ""
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var selectedRoom: HouseRoom?
    @State private var isRepeat: Bool = false
    @State private var isAlarmOn: Bool = false
    @State private var selectedAssignee: HouseInMember?
    @State private var houseId: Int = Int(UserDefaults.standard.string(forKey: "houseId") ?? "0") ?? 0
    @State private var userId: Int = Int(UserDefaults.standard.string(forKey: "userId") ?? "0") ?? 0
    @EnvironmentObject var triggerVM: TriggerViewModel
    
    // 저장 버튼 활성화 조건
    private var isFormValid: Bool {
        !title.isEmpty && selectedRoom != nil && selectedAssignee != nil && !dueDate.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 제목 입력
                TextField("할일 제목", text: $title)
                
                // 메모 입력
                TextField("메모(선택사항)", text: $memo)
                
                // 구역 선택
                NavigationLink(destination: RoomSelectionView(selectedRoom: $selectedRoom)) {
                    HStack {
                        Text("구역 선택")
                        Spacer()
                        if let room = selectedRoom {
                            Text(room.room_name).foregroundColor(.gray)
                        }
                    }
                }
                
                // 날짜 선택
                NavigationLink {
                    DateSelectionView(dueDate: $dueDate)
                } label: {
                    HStack {
                        Text("날짜")
                        Spacer()
                        Text(dueDate).foregroundColor(.gray)
                    }
                }
                
                // 반복 설정
                HStack {
                    Text("반복")
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray)
                }
                
                // 알람 설정
                Toggle("알람", isOn: $isAlarmOn)
                
                // 담당자 지정
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
            .navigationTitle("새 작업 추가")
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
        guard let roomId = selectedRoom?.id else {
            return
        }
        
        viewModel.onTaskAdded = {
            self.viewModel.fetchTasks(houseId: self.houseId)
            
            self.viewModel.isLoading = false
            self.viewModel.fetchMyTasks(userId: self.userId)

            print("saveTask 끝")
            
            //알람?
            if(isAlarmOn){
                triggerVM.intervalTrigger()
            }
        }

        print("saveTask 시작")
        viewModel.addTask(
            houseRoomId: roomId,
            title: title,
            assigneeId: selectedAssignee != nil ? [selectedAssignee!.userId] : [],
            memo: memo.isEmpty ? nil : memo,
            alarm: isAlarmOn,
            dueDate: dueDate.isEmpty ? nil : dueDate
        )
        
        isPresented = false
    }
}

#Preview {
    AddTaskView(isPresented: .constant(true))
}
