//
//  MyTaskListView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/24/24.
//

import SwiftUI

struct MyTaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var isShowingAddTask = false
    let userId: Int
    
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
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isShowingAddTask = true
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
                        .sheet(isPresented: $isShowingAddTask) {
                            AddTaskView(isPresented: $isShowingAddTask)
                                .presentationDetents([.large])
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
                MyTaskListView(userId: 1)
            }
