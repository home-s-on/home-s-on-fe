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
    @StateObject private var viewModel = TaskViewModel()
    let userId: Int
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    @State private var isShowingAddTask = false // 추가

    
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
                    } else if viewModel.isFetchError {
                        Text(viewModel.message)
                            .foregroundColor(.red)
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
                                
                                ForEach(viewModel.tasks) { task in
                                    TaskRowView(task: task)
                                        .padding(.horizontal)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchMyTasks(userId: userId)
                }
                
                // AddTaskButton에 필요한 매개변수 전달
                AddTaskButton(isShowingAddTask: $isShowingAddTask, viewModel: viewModel, houseId: userId) // 수정
            }
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

#Preview {
                let _ = UserDefaults.standard.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTYsImlhdCI6MTczMzA1NjE2NiwiZXhwIjoxNzM1NjQ4MTY2fQ.kEMlNTg7gpvn1NMPhNgtTtJGGFU9LIwz6P78zBuGiXA", forKey: "token")
                MyTaskListView(userId: 16)
            }
