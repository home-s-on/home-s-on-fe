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
    
    // 오늘 날짜의 시작을 기준으로 설정
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        VStack {
            DatePicker("날짜 선택",
                      selection: $selectedDate,
                      in: today..., // 오늘 이후의 날짜만 선택 가능
                      displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            Button("선택") {
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
