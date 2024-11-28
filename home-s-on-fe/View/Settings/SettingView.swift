//
//  SettingView.swift
//  home-s-on-fe
//
//  Created by 박미정 on 11/28/24.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        
        VStack (spacing: 30){
            
            WideImageButton(icon: "", title: "멤버 확인하기", backgroundColor: .white, borderColer: .gray, textColor: .black) {
                
            }
            WideImageButton(icon: "", title: "지난 할 일", backgroundColor: .white, borderColer: .gray, textColor: .black) {
                
            }
            WideImageButton(icon: "", title: "초대 코드", backgroundColor: .white, borderColer: .gray, textColor: .black) {
                
            }
            
        }
        
    }
}

#Preview {
    SettingView()
}
