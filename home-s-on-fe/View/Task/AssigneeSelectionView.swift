//
//  AssigneeSelectionView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/28/24.
//

import SwiftUI
import Alamofire

struct AssigneeSelectionView: View {
    @StateObject private var viewModel = GetMembersInHouseViewModel()
    @Binding var selectedAssignee: HouseInMember?
    @State private var isDropdownOpen = false

    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isDropdownOpen.toggle()
                }
            }) {
                HStack {
                    Text(selectedAssignee?.nickname ?? "담당자 선택")
                    Spacer()
                    Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }

            if isDropdownOpen {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.members, id: \.userId) { member in
                            Button(action: {
                                selectedAssignee = member
                                withAnimation {
                                    isDropdownOpen = false
                                }
                            }) {
                                HStack {
                                    Text(member.nickname)
                                    Spacer()
                                    if member.isOwner {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .shadow(radius: 2)
            }
        }
        .onAppear {
            viewModel.getMembersInHouse()
        }
        .alert(isPresented: $viewModel.isGetMembersShowing) {
            Alert(title: Text("알림"), message: Text(viewModel.message), dismissButton: .default(Text("확인")))
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4))
                }
            }
        )
    }
}

struct AssigneeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AssigneeSelectionView(selectedAssignee: .constant(nil))
            .environmentObject(GetMembersInHouseViewModel())
    }
