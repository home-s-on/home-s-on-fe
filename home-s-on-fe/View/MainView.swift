import SwiftUI

struct MainView: View {
    @StateObject var viewModel = TaskViewModel()
    @StateObject var appState = SelectedTabViewModel()
    @StateObject private var getHouseInMemberVM = GetMembersInHouseViewModel()
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")
    @State private var userId: Int = UserDefaults.standard.integer(forKey: "userId")
   
    
    var body: some View {
        TabView(selection: $appState.selectedTab) { 
                TaskListView(houseId: houseId)
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("할일 목록")
                    }
                    .tag(0)
                
                MyTaskListView(userId: userId)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("나의 할일")
                    }
                    .tag(1)
                    
                SettingView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("설정")
                    }
                    .tag(2)
            }
            .environmentObject(viewModel)
            .environmentObject(getHouseInMemberVM)
            .environmentObject(appState)
            .navigationBarBackButtonHidden(true)
        }
}

#Preview {
    MainView()
}
