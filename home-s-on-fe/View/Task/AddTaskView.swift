import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var membersViewModel: GetMembersInHouseViewModel
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    @EnvironmentObject var triggerVM: TriggerViewModel
    @EnvironmentObject var notificationVM : NotificationViewModel
    @State private var dueDate: String = ""
    @State private var endDate: String = ""
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
           // 제목, 선택된 방, 담당자, 마감 날짜가 모두 입력되었는지 확인
           !title.isEmpty && selectedRoom != nil && !selectedAssignees.isEmpty && (!selectedDays.isEmpty ? !endDate.isEmpty : !dueDate.isEmpty)
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
                    
                    if selectedDays.isEmpty {  // 반복이 설정되지 않은 경우
                        NavigationLink {
                            DateSelectionView(dueDate: $dueDate)
                        } label: {
                            HStack {
                                Text("마감 날짜")
                                Spacer()
                                Text(dueDate).foregroundColor(.gray)
                            }
                        }
                    } else {  // 반복이 설정된 경우
                        NavigationLink {
                            DateSelectionView(dueDate: $endDate)
                        } label: {
                            HStack {
                                Text("반복 종료 날짜")
                                Spacer()
                                Text(endDate).foregroundColor(.gray)
                            }
                        }
                    }
                    
                    
                    Toggle("알람", isOn: $isAlarmOn)
                        .onChange(of: isAlarmOn) { newValue in
                            if newValue {
                                notificationVM.checkNotificationStatus { status in
                                    switch status {
                                    case .denied, .notDetermined:
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
                    leading:
                        Button("취소") { isPresented = false },
                    trailing:
                        Button("저장") { saveTask() }.disabled(!isFormValid)
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
                dueDate: selectedDays.isEmpty ? dueDate : nil,  // 일반 할일은 dueDate 사용
                repeatDay: selectedDays.isEmpty ? nil : Array(selectedDays),
                endDate: selectedDays.isEmpty ? nil : endDate  // 반복 할일은 endDate 사용
            )

            viewModel.onTaskAdded = {
                if appState.selectedTab == 0 {
                    self.viewModel.fetchTasks(houseId: self.houseId)
                } else if appState.selectedTab == 1 {
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
