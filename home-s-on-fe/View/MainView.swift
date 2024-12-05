import SwiftUI

struct MainView: View {
    @StateObject var viewModel = TaskViewModel()
//    let taskVM = TaskViewModel()
    @StateObject private var getHouseInMemberVM = GetMembersInHouseViewModel()
    
    var body: some View {
        TabView {
            TaskListView(houseId: 1)
                .tabItem {
                    Image(systemName: "checklist")
                    Text("할일 목록")
                }
            
            MyTaskListView(userId: 1)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("나의 할일")
                }
                
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("설정")
                }
        }
        .environmentObject(viewModel)
        .environmentObject(getHouseInMemberVM)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainView()
}
