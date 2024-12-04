//
//  RepeatSelectionView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 12/5/24.
//

import SwiftUI

struct RepeatSelectionView: View {
    @Binding var selectedDays: Set<Int>
    @Environment(\.presentationMode) var presentationMode
    
    let daysOfWeek = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<7) { index in
                    Button(action: {
                        if selectedDays.contains(index) {
                            selectedDays.remove(index)
                        } else {
                            selectedDays.insert(index)
                        }
                    }) {
                        HStack {
                            Text(daysOfWeek[index])
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedDays.contains(index) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("반복", displayMode: .inline)
            .navigationBarItems(leading: Button("뒤로") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
}

#Preview {
    RepeatSelectionView(selectedDays: .constant([1, 3, 5]))
}
