//
//  TaskListView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/22/24.
//

import SwiftUI
import Kingfisher

struct TaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var photoURL: URL?
    @State private var errorMessage: String?
    let houseId: Int
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    //프로필 영역
                    HStack(spacing: 12) {  // HStack 추가

                    if let photoURL = URL(string: "\(APIEndpoints.blobURL)/\(photo)") {
                        KFImage(photoURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                    
                    Text(nickname)
                        .font(.system(size: 18, weight: .medium))

                        
                        Spacer()
                    }
                    .padding()
                    
                    // 에러메세지 할일 목록
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.isFetchError {
                        Text(viewModel.message)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.tasks) { task in
                                    TaskRowView(task: task)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                
                AddTaskButton()
            }
            .onAppear {
                viewModel.fetchTasks(houseId: houseId)
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}

#Preview {
    let _ = UserDefaults.standard.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzMyNzIyMzc1LCJleHAiOjE3MzI4MDg3NzV9.6gcH_Dwa5gGi9hYDIAvsKosJBoij93Na9oxjfGlAb8g", forKey: "token")
    return TaskListView(houseId: 1)
}
