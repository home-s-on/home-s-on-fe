//
//  ContentView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/18/24.
//

import SwiftUI
import KakaoSDKCommon

struct ContentView: View {
    @State var navigateToLoginView = false
    
    var body: some View {
        VStack {
            if navigateToLoginView {
                LoginView()
            } else {
                EntryView()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
