import SwiftUI

struct EnterInviteCodeView: View {
    @EnvironmentObject var joinToHouseVM: JoinToHouseViewModel
    @State private var inviteCode = ""

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("초대코드를 입력해주세요")
                    .font(.title)

                CustomTextField(icon: "", placeholder: "받은 초대 코드 입력", text: $inviteCode)

            }.padding(.horizontal)
                .padding(.bottom, 400)
            
            WideImageButton(icon: "", title: "확인", backgroundColor: .blue) {
                joinToHouseVM.joinToHouse(inviteCode: inviteCode)
            }
            
            NavigationLink(destination: MainView(), isActive: $joinToHouseVM.isNavigatingToMain) {
                EmptyView()
                }
            }
        
            .alert("입장 실패", isPresented: $joinToHouseVM.isJoinToHouseShowing) {
                Button("확인") {
                    joinToHouseVM.isJoinToHouseError = false
                }
            } message: {
                Text(joinToHouseVM.message)
            }
    }
}

#Preview {
    let joinToHouseVM = JoinToHouseViewModel()
    EnterInviteCodeView().environmentObject(joinToHouseVM)
}
