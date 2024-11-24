//
//  EntryView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/18/24.
//

import SwiftUI

struct EntryView: View {
    @StateObject private var loginVM = LoginViewModel(profileViewModel: ProfileViewModel())

    var body: some View {
        VStack {
            if loginVM.isLoggedIn {
                ProfileEditView()
                    .environmentObject(loginVM.profileViewModel!)
            } else {
                LoginView()
                    .environmentObject(loginVM)
                    .environmentObject(loginVM.profileViewModel!)
            }
        }
        .animation(.easeOut, value: loginVM.isLoggedIn)
    }
}

#Preview {
    let profileVM = ProfileViewModel()
    let loginVM = LoginViewModel(profileViewModel: profileVM)
    EntryView().environmentObject(loginVM)
}
