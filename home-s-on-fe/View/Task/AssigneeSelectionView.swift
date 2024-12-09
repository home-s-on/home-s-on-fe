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
                    if member.isOwner {
                        Text("작성자")
                            .font(.caption)
                            .padding(5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(5)
                    }
                    if selectedAssignees.contains(where: { $0.userId == member.userId }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedAssignees.contains(where: { $0.userId == member.userId }) {
                        // 이미 선택된 담당자를 탭하면 제거
                        if let existingMember = selectedAssignees.first(where: { $0.userId == member.userId }) {
                            selectedAssignees.remove(existingMember)
                        }
                    } else {
                        // 새로운 담당자 추가
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
