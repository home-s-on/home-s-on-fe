//
//  AddTaskView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/25/24.
//

import SwiftUI

struct AddTaskView: View {
    @Binding var isPresented: Bool
        @State private var title = ""
        @State private var memo = ""
        @State private var selectedRoom = ""
    var body: some View {
                NavigationView {
                    Form {
                        TextField("할일 제목", text: $title)
                        TextField("메모", text: $memo)
                        // 추가 필드들...
                    }
                    .navigationTitle("할일 추가")
                    .navigationBarItems(
                        leading: Button("취소") {
                            isPresented = false
                        },
                        trailing: Button("추가") {
                            // 할일 추가 로직
                            isPresented = false
                        }
                    )
                }
            }
        }

#Preview {
    AddTaskView(isPresented: .constant(true))
}
