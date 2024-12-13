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
    @EnvironmentObject var triggerVM: TriggerViewModel
    let userId: Int
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    
    // 통계 계산 프로퍼티
    private var todayTasks: [Task] {
        filterTasks(for: .today, completed: false)
    }
    
    private var upcomingTasks: [Task] {
        filterTasks(for: .upcoming, completed: false)
    }
    
    private var completedTasks: [Task] {
        viewModel.tasks.filter { $0.complete }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // 프로필 영역 표시
                    HStack(spacing: 12) {
                        let photoURL = URL(string: "\(APIEndpoints.blobURL)/\(photo)")
                        KFImage(photoURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .background(Color.clear)
                            .clipShape(Circle())
                        
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
                                    taskSection(title: "오늘 마감", tasks: todayTasks)
                                    taskSection(title: "예정된 할일", tasks: upcomingTasks)
                                    taskSection(title: "완료된 할일", tasks: completedTasks)
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
    
    //할일 섹션 생성
    private func taskSection(title: String, tasks: [Task]) -> some View {
        Group {
            if !tasks.isEmpty {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                        .environmentObject(viewModel)
                        .environmentObject(appState)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    //시간(오늘마감),완료여부 필터링
    private func filterTasks(for timeFrame: TimeFrame, completed: Bool) -> [Task] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let today = Calendar.current.startOfDay(for: Date())
        let currentDayOfWeek = Calendar.current.component(.weekday, from: Date()) - 1
        
        return viewModel.tasks.filter { task in
            guard task.complete == completed else { return false }
            
            // 반복 할일 처리
            if let repeatDay = task.repeatDay, !repeatDay.isEmpty {
                switch timeFrame {
                case .today:
                    // 오늘 요일 = 반복 요일 확인
                    return repeatDay.contains(currentDayOfWeek)
                case .upcoming:
                    // 다음 반복일 = 마감일 이전 확인
                    if let dueDateString = task.dueDate,
                       let dueDate = formatter.date(from: dueDateString) {
                        let nextDate = Calendar.current.nextDate(
                            after: today,
                            matching: DateComponents(weekday: repeatDay[0] + 1),
                            matchingPolicy: .nextTime
                        )
                        return nextDate != nil && nextDate! <= dueDate
                    }
                }
            }
            
            if let dueDateString = task.dueDate,
               let taskDate = formatter.date(from: dueDateString) {
                let startOfTaskDate = Calendar.current.startOfDay(for: taskDate)
                switch timeFrame {
                case .today:
                    return startOfTaskDate == today
                case .upcoming:
                    return startOfTaskDate > today
                }
            }
            
            return false
        }
    }
    //현재날짜->문자열
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

enum TimeFrame {
    case today //오늘
    case upcoming //예정
}
