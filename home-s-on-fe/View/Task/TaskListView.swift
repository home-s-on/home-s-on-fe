//
//  TaskListView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/22/24.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    let houseId: Int
    
    var body: some View {
        NavigationView {
            VStack {
                //프로필 영역
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                    
                    Text("ahn")
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                }
                .padding()
                
                // 할일 목록
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.tasks) { task in
                            TaskRowView(task: task)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                        // 할일 추가
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            )
            .onAppear {
                viewModel.fetchTasks(houseId: houseId)
            }
        }
    }
}

#Preview {
    TaskListView(houseId: 1)
}
