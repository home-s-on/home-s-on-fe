//
//  EntryView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/18/24.
//

import SwiftUI

struct EntryView: View {
    @EnvironmentObject var loginVM:LoginViewModel
    var body: some View {
        VStack{
            
            if loginVM.isLoggedIn {
                MainView()
            } else {
                LoginView()
            }
        }.animation(.easeOut, value:loginVM.isLoggedIn)
    }
}

#Preview {
    let loginVM = LoginViewModel()
    EntryView().environmentObject(loginVM)
}
