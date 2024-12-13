import SwiftUI

struct MainView: View {
    @StateObject var viewModel = TaskViewModel()
    @StateObject var selectedTabVM = SelectedTabViewModel()
    @StateObject var chatVM = ChatViewModel()
    @StateObject private var getHouseInMemberVM = GetMembersInHouseViewModel()
    @StateObject var notificationVM = NotificationViewModel()
    @StateObject var triggerVM = TriggerViewModel()
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
    
    var body: some View {
            TabView(selection: $selectedTabVM.selectedTab) {
                TaskListView(houseId: houseId)
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTabVM.selectedTab == 0 ? "checklist.checked" : "checklist")
                            Text("할일 목록")
                        }
                    }
                    .tag(0)
                
                MyTaskListView(userId: userId)
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTabVM.selectedTab == 1 ? "calendar.badge.clock" : "calendar")
                            Text("나의 할일")
                        }
                    }
                    .tag(1)
            
                ChatView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTabVM.selectedTab == 2 ? "lightbulb.fill" : "lightbulb")
                            Text("Chat AI")
                        }
                    }
                    .tag(2)
                    
                SettingView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTabVM.selectedTab == 3 ? "gearshape.fill" : "gearshape")
                            Text("설정")
                        }
                    }
                    .tag(3)
            }
            .accentColor(.mainColor)
            .environmentObject(viewModel)
            .environmentObject(getHouseInMemberVM)
            .environmentObject(selectedTabVM)
            .environmentObject(notificationVM)
            .environmentObject(chatVM)
            .environmentObject(triggerVM)
            .navigationBarBackButtonHidden(true)
        }
    }

    // 탭바 스타일 수정을 위한 확장
    extension UITabBar {
        static func changeAppearance() {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    struct MainView_Previews: PreviewProvider {
        static var previews: some View {
            MainView()
                .onAppear {
                    UITabBar.changeAppearance()
                }
        }
    }

#Preview {
    MainView()
}
