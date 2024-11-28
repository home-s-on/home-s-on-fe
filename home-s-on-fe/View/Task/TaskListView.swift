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
    let houseId: Int
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    
    var body: some View {
        NavigationView {
            VStack {
                //프로필 영역
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
