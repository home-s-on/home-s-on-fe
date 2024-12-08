import SwiftUI

struct EnterInviteCodeView: View {
    @EnvironmentObject var joinToHouseVM: JoinToHouseViewModel
    @EnvironmentObject var getHouseIdVM: GetHouseIdViewModel
    @StateObject var joinMemberVM = JoinMemberViewModel()
    @State private var inviteCode = ""
//    @AppStorage("houseId") var houseId: Int?
    @State private var houseId: Int = UserDefaults.standard.integer(forKey: "houseId")

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("초대코드를 입력해주세요")
                    .font(.title)

                CustomTextField(icon: "", placeholder: "받은 초대 코드 입력", text: $inviteCode)

            }.padding(.horizontal)
                .padding(.bottom, 400)
            
            WideImageButton(icon: "", title: "확인", backgroundColor: .blue) {
                getHouseIdVM.getHouseId(inviteCode: inviteCode) { houseId in
                    if let id = houseId {
                        joinMemberVM.joinMember(houseId: id)
                        joinToHouseVM.joinToHouse(inviteCode: inviteCode)
                    } else {
                        print("houseId 에러로 인한 집 입장 실패")
                    }
                }
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
