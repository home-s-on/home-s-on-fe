import SwiftUI
import Kingfisher
import Alamofire

struct MyTaskListView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    let userId: Int
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var photo: String = UserDefaults.standard.string(forKey: "photo") ?? ""
    
    // 오늘 마감인 할일 필터링
    private var todayTasks: [Task] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let today = Calendar.current.startOfDay(for: Date())
        
        return viewModel.tasks.filter { task in
            if let dueDateString = task.dueDate,
               let taskDate = formatter.date(from: dueDateString) {
                let startOfTaskDate = Calendar.current.startOfDay(for: taskDate)
                return startOfTaskDate == today
            }
            return false
        }
    }

    // 다른 날짜 마감인 할일 필터링
    private var otherTasks: [Task] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let today = Calendar.current.startOfDay(for: Date())
        
        return viewModel.tasks.filter { task in
            if let dueDateString = task.dueDate,
               let taskDate = formatter.date(from: dueDateString) {
                let startOfTaskDate = Calendar.current.startOfDay(for: taskDate)
                return startOfTaskDate != today
            }
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
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
                    
                    // 로딩 상태 처리
                    if viewModel.isLoading {
                        // 로딩 중일 때 스켈레톤 뷰 표시 (최소 개수 조정)
                        ForEach(0..<6) { _ in // 예시로 6개의 스켈레톤을 표시
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 90)
                                .cornerRadius(10)
                                .padding(.bottom, 4)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                        }
                    } else if viewModel.tasks.isEmpty && !viewModel.isFetchError {
                        // 등록된 할 일이 없을 때 메시지 표시
                        Text("등록된 할일이 없습니다")
                            .foregroundColor(.gray)
                            .padding()
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
                                
                                // 오늘 마감 할일 섹션
                                if !todayTasks.isEmpty {
                                    Text("오늘 마감")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ForEach(todayTasks) { task in
                                        TaskRowView(task: task)
                                            .environmentObject(viewModel)
                                            .environmentObject(appState)
                                            .padding(.horizontal)
                                    }
                                }
                                
                                // 다른 할일 섹션
                                if !otherTasks.isEmpty {
                                    Text("예정된 할일")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.top, 20)
                                    
                                    ForEach(otherTasks) { task in
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
                    viewModel.fetchMyTasks(userId: userId) // 데이터 가져오기 호출
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
            Text(viewModel.message) // 에러 메시지 표시
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}
