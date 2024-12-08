//
//  AppState.swift
//  home-s-on-fe
//
//  Created by songhee jeong on 12/8/24.
//
import SwiftUI

// class AppState: ObservableObject {
//    @Published var isAppLoggedIn = false
// }

class AppState: ObservableObject {
    @Published var rootView: RootView = .entry
}

enum RootView {
    case entry
    case main
}
