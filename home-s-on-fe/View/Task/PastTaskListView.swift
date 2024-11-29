//
//  PastTaskListView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/29/24.
//

import SwiftUI

struct PastTaskListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TaskViewModel
    
    //더미데이터
    init() {
        let viewModel = TaskViewModel()
        viewModel.tasks = [
            Task(id: 1, houseId: 1, houseRoomId: 1, userId: 1, title: "음식물 쓰레기 봉투 구입", memo: nil, alarm: nil, assigneeId: [1], dueDate: "2024-11-08", complete: true, createdAt: "", updatedAt: "", houseRoom: nil, assignees: nil),
            Task(id: 2, houseId: 1, houseRoomId: 2, userId: 1, title: "휴지 채우기", memo: nil, alarm: nil, assigneeId: [1], dueDate: "2024-11-08", complete: true, createdAt: "", updatedAt: "", houseRoom: nil, assignees: nil),
            Task(id: 3, houseId: 1, houseRoomId: 2, userId: 1, title: "아들 빨래하기", memo: nil, alarm: nil, assigneeId: [1], dueDate: "2024-11-07", complete: true, createdAt: "", updatedAt: "", houseRoom: nil, assignees: nil),
            Task(id: 4, houseId: 1, houseRoomId: 3, userId: 1, title: "주방세제 구입", memo: nil, alarm: nil, assigneeId: [1], dueDate: "2024-11-07", complete: true, createdAt: "", updatedAt: "", houseRoom: nil, assignees: nil),
            Task(id: 5, houseId: 1, houseRoomId: 1, userId: 1, title: "주방세제 사기", memo: nil, alarm: nil, assigneeId: [1], dueDate: "2024-10-31", complete: true, createdAt: "", updatedAt: "", houseRoom: nil, assignees: nil),
            Task(id: 6, houseId: 1, houseRoomId: 2, userId: 1, title: "휴지 채우기", memo: nil, alarm: nil, assigneeId: [1], dueDate: "2024-10-31", complete: true, createdAt: "", updatedAt: "", houseRoom: nil, assignees: nil)
        ]
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    
    var body: some View {
        VStack {
            //네비게이션 바 - 뒤로가기 버튼
            HStack {
                Button(action: {
                    dismiss()
                })
                {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("지난 할 일")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        //날짜 내림차순 정렬
                        ForEach(groupedTasks.keys.sorted(by: >), id: \.self){ date in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(date)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                
                                ForEach(groupedTasks[date] ?? []) { task in
                                    VStack(spacing: 0) {
                                        Text(task.title)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 12)
                                            .foregroundColor(task.complete ? .gray : .black)  // 완료:회색, 미완료:검정색
                                            .strikethrough(task.complete)  // 완료:취소선
                                        
                                        Divider()//항목구분선
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
            
    //날짜 그룹
    private var groupedTasks: [String: [Task]] {
        Dictionary(grouping: viewModel.tasks) { task in
            formatDate(from: task.dueDate ?? "")
        }
    }
    
    //날짜 포맷
    private func formatDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        
        formatter.dateFormat = "MM월 dd일 E"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        PastTaskListView()
    }
    
}
