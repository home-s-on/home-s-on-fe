import SwiftUI
import Alamofire

class TaskManagementViewModel: ObservableObject {
    @Published var message = ""
    @Published var isFetchError = false
    @Published var isLoding = false
    var onTaskAdded: (() -> Void)?
    
    //할일 추가
    //func addTask
}

