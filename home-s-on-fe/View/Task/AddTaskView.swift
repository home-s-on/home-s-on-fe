import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var membersViewModel: GetMembersInHouseViewModel
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    @EnvironmentObject var triggerVM: TriggerViewModel
    @EnvironmentObject var notificationVM : NotificationViewModel
    @State private var dueDate: String = ""
    @Binding var isPresented: Bool
    @Binding var showingNotificationAlert: Bool
    @State private var title: String = ""
    @State private var memo: String = ""
    @State private var selectedRoom: HouseRoom?
    @State private var isRepeat: Bool = false
    @State private var isAlarmOn: Bool = false
    @State private var selectedAssignees: Set<HouseInMember> = []  // 변경
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var showRepeatSelection = false
    @State private var selectedDays: Set<Int> = []
    let daysOfWeek = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]
    
    private var isFormValid: Bool {
        !title.isEmpty && selectedRoom != nil && !selectedAssignees.isEmpty && !dueDate.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("할일 제목", text: $title)
                
                TextField("메모(선택사항)", text: $memo)
                
                NavigationLink(destination: RoomSelectionView(selectedRoom: $selectedRoom)) {
                    HStack {
                        Text("구역 선택")
                        Spacer()
                        if let room = selectedRoom {
                            Text(room.room_name).foregroundColor(.gray)
                        }
                    }
                }
                
                NavigationLink {
                    DateSelectionView(dueDate: $dueDate)
                } label: {
                    HStack {
                        Text("마감 날짜")
                        Spacer()
                        Text(dueDate).foregroundColor(.gray)
                    }
                }
                
                NavigationLink(destination: RepeatSelectionView(selectedDays: $selectedDays)) {
                    HStack {
                        Text("반복")
                        Spacer()
                        if !selectedDays.isEmpty {
                            Text(selectedDays.sorted().map { daysOfWeek[$0] }.joined(separator: ", "))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Toggle("알람", isOn: $isAlarmOn)
                    .onChange(of: isAlarmOn) { newValue in
                        if newValue {
                            notificationVM.checkNotificationStatus { status in
                                switch status {
                                //case .authorized:
                                case .denied, .notDetermined:
                                    print("알림 권한이 등록되지 않았습니다.")
                                    //사용자에게 알림 설정 권유하는 알림 표시
                                    DispatchQueue.main.async {
                                        self.showingNotificationAlert = true
                                    }
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                
                
                NavigationLink(destination: AssigneeSelectionView(selectedAssignees: $selectedAssignees).environmentObject(membersViewModel)) {
                    HStack {
                        Text("담당자 지정")
                        Spacer()
                        if !selectedAssignees.isEmpty {
                            Text(selectedAssignees.map { $0.nickname }.joined(separator: ", "))
                                .foregroundColor(.gray)
                        }
                    }
                }
               
            }
            .navigationTitle("새 작업 추가")
            .navigationBarItems(
                leading: Button("취소") {
                    isPresented = false
                },
                trailing: Button("저장") {
                    saveTask()
                }
                .disabled(!isFormValid)
            )
           

        }
    }
    
    fileprivate func setupAndSendNotifications() {
        triggerVM.calenderTrigger(subtitle: title, body: dueDate)
        triggerVM.sendPushNotification(
            assigneeId: Array(selectedAssignees).map { $0.userId },  // Set을 Array로 변환하고 userId 매핑
            title: title,
            subtitle: nickname+"님이 당신의 할일을 등록했습니다." ,
            body: title
        )
    }
    
    private func saveTask() {
        guard let roomId = selectedRoom?.id else { return }

        print("saveTask 시작")
        viewModel.addTask(
          houseRoomId: roomId,
          title: title,
          assigneeId: selectedAssignees.map { $0.userId },
          memo: memo.isEmpty ? nil : memo,
          alarm: isAlarmOn,
          dueDate: dueDate.isEmpty ? nil : dueDate,
          repeatDay: selectedDays.isEmpty ? nil : Array(selectedDays)  // 반복 요일 추가
          
        )

        
        
        
        viewModel.onTaskAdded = {
            if appState.selectedTab == 0 {
                // "할일 목록" 탭일 때
                self.viewModel.fetchTasks(houseId: self.houseId)
            } else if appState.selectedTab == 1 {
                // "나의 할일" 탭일 때
                self.viewModel.isLoading = false
                self.viewModel.fetchMyTasks(userId: self.userId)
            }
            
            print("saveTask 끝")
            
            // 알람 설정
            if isAlarmOn {
                notificationVM.checkNotificationStatus { status in
                    switch status {
                    case .authorized:
                        self.setupAndSendNotifications()
                    case .denied, .notDetermined:
                        print("알림 권한이 등록되지 않았습니다.")
                    default:
                        break
                    }
                }
            }
        }
        
        isPresented = false
    }
}


