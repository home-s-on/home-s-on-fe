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
        NavigationView {
            List {
                ForEach(viewModel.houseMembers, id: \.userId) { member in
                    Button(action: {
                        if selectedAssignees.contains(member) {
                            selectedAssignees.remove(member)
                        } else {
                            selectedAssignees.insert(member)
                        }
                    }) {
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
                            if selectedAssignees.contains(member) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
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
}

struct AssigneeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AssigneeSelectionView(selectedAssignees: .constant([]))
            .environmentObject(GetMembersInHouseViewModel())
    }
}
