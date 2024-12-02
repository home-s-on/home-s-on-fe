//
//  AppleLoginView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 11/26/24.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginView: View {
    @EnvironmentObject var appleLoginVM: AppleLoginViewModel

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: configureAppleSignIn,
            onCompletion: appleLoginVM.handleAppleSignInResult
        )
        .frame(height: 45)
        .padding()
    }
    
    private func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
}

#Preview {
    let appleLoginVM = AppleLoginViewModel()
    AppleLoginView().environmentObject(appleLoginVM)
}
