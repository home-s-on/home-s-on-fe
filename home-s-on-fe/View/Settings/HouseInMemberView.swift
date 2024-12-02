//
//  HouseInMemberView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 12/2/24.
//
import SwiftUI

struct HouseInMemberView: View {
    @EnvironmentObject var viewModel: GetMembersInHouseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            // 네비게이션 바
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("멤버 목록")
                    .font(.headline)
                Spacer()
            }
            .padding()

            // 멤버 목록
            List(viewModel.houseMembers, id: \.userId) { member in
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
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.getMembersInHouse()
        }
    }
        
}

#Preview {
    let getMemberInHouseVM = GetMembersInHouseViewModel()
    HouseInMemberView().environmentObject(getMemberInHouseVM)
}





