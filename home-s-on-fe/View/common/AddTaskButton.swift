//
//  AddTaskButton.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/28/24.
//

import SwiftUI
import UserNotifications

struct AddTaskButton: View {
    @State private var isShowingAddTask = false
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var triggerVM: TriggerViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    @EnvironmentObject var notificationVM : NotificationViewModel
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State var showingNotificationAlert = false
    
    
    var body: some View {
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
                        .background(Color.mainColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isShowingAddTask) {
            AddTaskView(isPresented: $isShowingAddTask, showingNotificationAlert: $showingNotificationAlert)
                .environmentObject(viewModel)  // viewModel을 전달
                .presentationDetents([.large])
                .environmentObject(TriggerViewModel())
                .environmentObject(appState)
              
                .alert("알림 설정", isPresented: $showingNotificationAlert) {
                    Button("확인") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    Button("취소") {
                        print("알람 설정 취소")
                    }
                } message: {
                    Text("알림을 받으려면 설정에서 알림을 허용해주세요")
                }
        }
    }
    
}



//#Preview {
//    ZStack {
//        Color.white.edgesIgnoringSafeArea(.all) // 배경색 추가
//        AddTaskButton ()
//    }
//}
