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
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAssignee: HouseInMember?

    var body: some View {
        VStack {
            // 네비게이션 바
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("담당자 선택")
                    .font(.headline)
                Spacer()
            }
            .padding()

            // 멤버 목록
            List(viewModel.houseMembers, id: \.userId) { member in
                Button(action: {
                    selectedAssignee = member
                    dismiss()
                }) {
                    HStack {
                        Text(member.nickname)
                        Spacer()
                        if member.isOwner {
                            Text("집주인")
                                .font(.caption)
                                .padding(5)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(5)
                        }
                        if selectedAssignee?.userId == member.userId {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.getMembersInHouse()
        }
    }
}

struct AssigneeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AssigneeSelectionView(selectedAssignee: .constant(nil))
            .environmentObject(GetMembersInHouseViewModel())
    }
}
