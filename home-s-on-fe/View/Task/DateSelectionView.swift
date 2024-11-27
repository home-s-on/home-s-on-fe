//
//  DateSelectionView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/28/24.
//

import SwiftUI

struct DateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @Binding var dueDate: String
    
    var body: some View {
        VStack {
            DatePicker("날짜 선택",
                      selection: $selectedDate,
                      displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            Button("선택") {
                // 선택된 날짜 -> 문자열로 변환
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                dueDate = formatter.string(from: selectedDate)
                dismiss()
            }
            .padding()
        }
        .navigationTitle("날짜 선택")
    }
}

#Preview {
    NavigationView {
           DateSelectionView(dueDate: .constant("2024-11-28"))
       }
}
