//
//  AssigneeSelectionView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/28/24.
//

import SwiftUI
import Alamofire

struct AssigneeSelectionView: View {
    @EnvironmentObject var viewModel: GetMembersInHouseViewModel
    @Binding var selectedAssignees: Set<HouseInMember>
    
    var body: some View {
        List {
            ForEach(viewModel.houseMembers, id: \.userId) { member in
                HStack {
                    Text(member.nickname)
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedAssignees.contains(where: { $0.userId == member.userId }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedAssignees.contains(where: { $0.userId == member.userId }) {
                        if let existingMember = selectedAssignees.first(where: { $0.userId == member.userId }) {
                            selectedAssignees.remove(existingMember)
                        }
                    } else {
                        selectedAssignees.insert(member)
                    }
                }
            }
        }
        .navigationTitle("담당자 선택")
        .onAppear {
            viewModel.getMembersInHouse()
        }
    }
}
