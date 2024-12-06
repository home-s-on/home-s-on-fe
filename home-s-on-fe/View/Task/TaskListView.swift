//
//  TaskListView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/22/24.
//

import SwiftUI
import Kingfisher

struct TaskListView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
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
                        let photoURL = URL(string: "\(APIEndpoints.blobURL)/\(photo)")
                        KFImage(photoURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        Text(nickname)
                            .font(.system(size: 18, weight: .medium))
                        
                        
                        Spacer()
                    }
                    .padding()
                    
                    // 에러메세지 할일 목록
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                if viewModel.tasks.isEmpty && !viewModel.isFetchError {
                                    Text("등록된 할일이 없습니다")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ForEach(viewModel.tasks) { task in
                                        TaskRowView(task: task)
                                            .environmentObject(viewModel)
                                            .environmentObject(appState)
                                            .padding(.horizontal)
                                        
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchTasks(houseId: houseId)
                
            }
                AddTaskButton()
                    .environmentObject(appState)
            }
            .alert("오류", isPresented: $viewModel.isFetchError) {
                       Button("확인") {
                           viewModel.isFetchError = false
                }
            } message: {
                Text(errorMessage ?? "모든 할 일을 불러 올 수 없습니다")
            }
        }
    }
}

//#Preview {
//    let _ = UserDefaults.standard.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzMyNzIyMzc1LCJleHAiOjE3MzI4MDg3NzV9.6gcH_Dwa5gGi9hYDIAvsKosJBoij93Na9oxjfGlAb8g", forKey: "token")
//    return TaskListView(houseId: 1).environmentObject(TaskViewModel())
//}
