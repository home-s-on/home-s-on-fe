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
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
    @EnvironmentObject var triggerVM: TriggerViewModel
    //반복선택
    @State private var showRepeatSelection = false
    @State private var selectedDays: Set<Int> = []
    let daysOfWeek = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]
    


    
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
                NavigationLink(destination: RepeatSelectionView(selectedDays: $selectedDays)) {
                    HStack {
                        Text("반복")
                        Spacer()
                        if !selectedDays.isEmpty {
                            Text(selectedDays.sorted().map { daysOfWeek[$0] }.joined(separator: ", "))
                                .foregroundColor(.gray)
                        }
                    }
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
                //triggerVM.intervalTrigger(subtitle: title, body: dueDate)
                triggerVM.calenderTrigger(subtitle: title, body: dueDate)
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
