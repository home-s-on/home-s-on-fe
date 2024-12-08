import SwiftUI

struct SettingView: View {
    @State private var isShowInviteCode = false
    @State private var isShowPastTasks = false
    @State private var isShowHouseInMembers = false
    @State private var showLogoutAlert = false
    @State private var navigateToLoginView = false  // 로그인 화면으로 이동할 상태 변수 추가
    @EnvironmentObject var getHouseInMemberVM : GetMembersInHouseViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack (spacing: 40){
            SettingButton(icon: "", title: "멤버 확인하기", style: ButtonStyle(isButtonShadowVisible: true)) {
                print("멤버 확인하기 버튼 탭됨")
                getHouseInMemberVM.getMembersInHouse()
                isShowHouseInMembers = true
            }
            SettingButton(icon: "", title: "지난 할 일", style: ButtonStyle(isButtonShadowVisible: true)) {
                print("지난 할 일 버튼 탭됨")
                isShowPastTasks = true
            }
            SettingButton(icon: "", title: "초대 코드", style: ButtonStyle(isButtonShadowVisible: true)) {
                print("초대 코드 버튼 탭됨")
                isShowInviteCode = true
            }
            .padding(.bottom, 300)
            
            Text("로그아웃할래요!")
                .font(.footnote)
                .foregroundColor(.gray)
                .underline()
                .onTapGesture {
                    showLogoutAlert = true
                }
        }
        .navigationBarTitle("설정", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .navigationDestination(isPresented: $isShowInviteCode) {
            InviteMemberView(isFromSetting: true)
        }
        .navigationDestination(isPresented: $isShowPastTasks) {
            PastTaskListView()
        }
        .navigationDestination(isPresented: $isShowHouseInMembers) {
            HouseInMemberView()
                .environmentObject(getHouseInMemberVM)
        }
        // 로그아웃 알림
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("로그아웃"),
                message: Text("정말 로그아웃하시겠습니까?"),
                primaryButton: .destructive(Text("확인")) {
                    logout() // 로그아웃 처리 함수 호출
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .onAppear {
            getHouseInMemberVM.getMembersInHouse()
        }
        .fullScreenCover(isPresented: $navigateToLoginView) {
            LoginView()
        }
    }
    
    // 로그아웃
    private func logout() {
        resetUserDefaults()
        navigateToLoginView = true  // 로그아웃 후 로그인 화면으로 이동
    }

    private func resetUserDefaults() {
        let defaults = UserDefaults.standard

        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "nickname")
        defaults.removeObject(forKey: "photo")
        defaults.removeObject(forKey: "inviteCode")
        defaults.removeObject(forKey: "houseId")
        defaults.removeObject(forKey: "isOwner")
    }
}

#Preview {
    SettingView().environmentObject(GetMembersInHouseViewModel())
}
