//
//  MyTaskListView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/24/24.
//

import SwiftUI
import Kingfisher
import Alamofire

struct MyTaskListView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    let userId: Int
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    
    
    var body: some View {
        NavigationView {
            ZStack {  // ZStack -> AddTaskButton 맨 위에 오도록
                VStack {
                    HStack(spacing: 12) {
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
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                // 오늘 날짜 표시
                                HStack {
                                    Text(formattedDate())
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    Spacer()
                                }
                                
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
                    viewModel.fetchMyTasks(userId: userId)
                }
                
                AddTaskButton()
                    .environmentObject(appState)
                            }
                        }
                        .alert("오류", isPresented: $viewModel.isFetchError) {
                            Button("확인") {
                                viewModel.isFetchError = false
                            }
                        } message: {
                            Text(viewModel.message)
                        }
                    }
  
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

//#Preview {
//                let _ = UserDefaults.standard.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTYsImlhdCI6MTczMzA1NjE2NiwiZXhwIjoxNzM1NjQ4MTY2fQ.kEMlNTg7gpvn1NMPhNgtTtJGGFU9LIwz6P78zBuGiXA", forKey: "token")
//                MyTaskListView(userId: 16)
//            }
