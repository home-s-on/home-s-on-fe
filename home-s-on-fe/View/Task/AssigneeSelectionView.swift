//
//  AssigneeSelectionView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/28/24.
//

import SwiftUI


struct AssigneeSelectionView: View {
    @StateObject private var viewModel = AssigneeViewModel()
    @Binding var selectedAssignees: [Int]
    
    var body: some View {
        List {
            ForEach(viewModel.houseMembers, id: \.userId) { member in
                HStack {
                    Text(member.nickname)
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .opacity(selectedAssignees.contains(member.userId) ? 1 : 0)
                }
                .onTapGesture {
                    toggleSelection(member.userId)
                }
            }
        }
        .onAppear {
            viewModel.fetchHouseMembers()
        }
        .navigationTitle("담당자 지정")
    }
    
    private func toggleSelection(_ userId: Int) {
        if selectedAssignees.contains(userId) {
            selectedAssignees.removeAll { $0 == userId }
        } else {
            selectedAssignees.append(userId)
        }
    }
}
#Preview {
    NavigationView {
        AssigneeSelectionView(selectedAssignees: .constant([]))
    }
}
