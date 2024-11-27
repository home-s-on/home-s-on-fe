//
//  AddTaskView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/25/24.
//

import SwiftUI

struct AddTaskView: View {
    @State private var dueDate: String = ""
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var selectedRoom: HouseRoom?
    @State private var isRepeat: Bool = false
    @State private var isAlarmOn: Bool = false
    @State private var selectedAssignees: [TaskUser] = []
        
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
                
                // 알람 설정 --> 변경 예정
                Toggle("알람", isOn: $isAlarmOn)
                
                // 담당자 지정
                NavigationLink(destination: AssigneeSelectionView()) {
                    Text("담당자 지정")
                }
            }
            .navigationTitle("새 작업 추가")
            .navigationBarItems(leading: Button("취소") {
                isPresented = false
            },
                                trailing: Button("저장") {
                isPresented = false
                    }
                )
            }
        }
    }

#Preview {
    AddTaskView(isPresented: .constant(true))
}
