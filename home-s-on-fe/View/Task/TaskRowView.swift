//
//  TaskRowView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/22/24.
//
import SwiftUI

struct TaskRowView: View {
    var task: Task // Task 모델을 사용합니다.

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let memo = task.memo {
                    Text(memo)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            //완료 여부에따라 색상 변경
            Text(task.complete ? "완료" : "진행 중")
                .font(.subheadline)
                .foregroundColor(task.complete ? .green : .orange)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    // 샘플 데이터
    let sampleTask = Task(id: 1, houseId: 1, houseRoomId: 1, userId: 1, title: "새로운 할일", memo: "테스트 메모", alarm: nil, assigneeId: [1], dueDate: Date(), complete: false, createdAt: Date(), updatedAt: Date())
    
    TaskRowView(task: sampleTask)
}
