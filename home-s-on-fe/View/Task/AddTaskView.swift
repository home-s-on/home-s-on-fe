//
//  AddTaskView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/25/24.
//

import SwiftUI

struct AddTaskView: View {
    //@StateObject private var viewModel = TaskViewModel()
    @ObservedObject var viewModel: TaskViewModel //수정
    @State private var dueDate: String = ""
    @Binding var isPresented: Bool
    let houseId: Int // 추가
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var selectedRoom: HouseRoom?
    @State private var isRepeat: Bool = false
    @State private var isAlarmOn: Bool = false
    @State private var selectedAssignee: HouseInMember?
    
    
    // 저장 버튼 활성화 조건
    private var isFormValid: Bool {
        !title.isEmpty && selectedRoom != nil
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
                
                //날짜 선택
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
        
        viewModel.addTask(
            houseRoomId: roomId,
            title: title,
            assigneeId: selectedAssignee != nil ? [selectedAssignee!.userId] : [],
            memo: memo.isEmpty ? nil : memo,
            alarm: isAlarmOn ? "on" : nil,
            dueDate: dueDate.isEmpty ? nil : dueDate
        ){ success in
            if success {
                viewModel.fetchTasks(houseId: houseId) // 집 ID로 작업 목록 업데이트
                isPresented = false // AddTaskView 닫기
                
            }
        }
    }
}

 

    #Preview {
        AddTaskView(viewModel: TaskViewModel(), isPresented: .constant(true), houseId: 1)
    }
