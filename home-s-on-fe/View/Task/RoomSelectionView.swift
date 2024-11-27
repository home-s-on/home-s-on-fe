//
//  RoomSelectionView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/26/24.
//

import SwiftUI

struct RoomSelectionView: View {
    @Binding var selectedRoom: HouseRoom?
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
       
       let rooms = [
           ("거실", Color.red),
           ("안방", Color.blue),
           ("화장실", Color.green),
           ("주방", Color.purple)
       ]
       
       var body: some View {
           List {
               ForEach(rooms, id: \.0) { room, color in
                   HStack {
                       // 컬러 도트
                       Circle()
                           .fill(color)
                           .frame(width: 10, height: 10)
                       
                       Text(room)
                           .padding(.leading, 8)
                       
                       Spacer()
                       
                       if isEditing {
                           Button("Delete") {
                               // 삭제 로직
                           }
                           .foregroundColor(.red)
                       }
                   }
                   .contentShape(Rectangle())
                   .onTapGesture {
                       // 선택 로직
                   }
               }
           }
           .navigationTitle("구역 선택")
           .navigationBarItems(
               leading: Button("취소") {
                   dismiss()
               },
               trailing: Button(isEditing ? "Done" : "Edit") {
                   isEditing.toggle()
               }
           )
       }
   }

#Preview {
    NavigationView {
            RoomSelectionView(selectedRoom: .constant(nil))
        }
}
