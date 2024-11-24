import SwiftUI

struct MainView: View {
    let taskVM = TaskViewModel()
    
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
                
            Text("설정")
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("설정")
                }
        }
        .environmentObject(taskVM)
    }
}

#Preview {
    MainView()
}
