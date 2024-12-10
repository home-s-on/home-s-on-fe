//
//  AddTaskButton.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/28/24.
//

import SwiftUI

struct AddTaskButton: View {
    @State private var isShowingAddTask = false
    @EnvironmentObject var viewModel: TaskViewModel
    @EnvironmentObject var triggerVM: TriggerViewModel
    @EnvironmentObject var appState: SelectedTabViewModel
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State var showingNotificationAlert = false
    @EnvironmentObject var notificationVM : NotificationViewModel
    
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
                .environmentObject(notificationVM)
                .alert("알림 설정", isPresented: $showingNotificationAlert) {
                    Button("확인") {
                        notificationVM.requestNotificationPermission { granted in
                            if granted {
                                print("알람 권한이 등록되었습니다.")
                            } else {
                                print("알람 권한이 거부되었습니다.")
                            }
                        }
                    }
                    Button("취소") {
                        print("알람 설정 취소")
                    }
                } message: {
                    Text("할 일 알람을 받고 싶으면 알림을 활성화해주세요")
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
