//
//  RoomSelectionView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/26/24.
//

import SwiftUI
import Alamofire

struct RoomSelectionView: View {
    @Binding var selectedRoom: HouseRoom?
       @Environment(\.dismiss) private var dismiss
       @StateObject private var viewModel = HouseRoomViewModel()
       @State private var isEditing = false
       @State private var showingAddSheet = false
    
    var body: some View {
            List {
                if viewModel.isLoading {
                    ProgressView("로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.rooms) { room in
                        HStack {
                            Circle()
                                .fill(getColor(for: room.room_name))
                                .frame(width: 10, height: 10)
                            
                            Text(room.room_name)
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            if isEditing {
                                Button("Delete") {
                                    viewModel.deleteRoom(id: room.id)
                                }
                                .foregroundColor(.red)
                            } else if selectedRoom?.id == room.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isEditing {
                                selectedRoom = room
                                dismiss()
                            }
                        }
                        .background(selectedRoom?.id == room.id ? Color.blue.opacity(0.1) : Color.clear)
                    }
                }
            }
            .navigationTitle("구역 선택")
            .navigationBarItems(
                trailing: HStack {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                    if !isEditing {
                        Button(action: {
                            showingAddSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            )
            .sheet(isPresented: $showingAddSheet) {
                NavigationView {
                    AddRoomView(viewModel: viewModel)
                }
            }
            .onAppear {
                viewModel.fetchRooms()
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    
    //추후 디자인 수정 예정
    private func getColor(for roomName: String) -> Color {
        switch roomName {
        case "거실": return .red
        case "안방": return .blue
        case "화장실": return .green
        case "주방": return .purple
        default: return .gray
        }
    }
}

struct AddRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var roomName = ""
    @ObservedObject var viewModel: HouseRoomViewModel
    
    var body: some View {
        Form {
            TextField("구역 이름", text: $roomName)
        }
        .navigationTitle("구역 추가")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    viewModel.addRoom(name: roomName)
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
            }
        }
    }
}
#Preview {
    // 포스트맨에서 받은 실제 토큰을 저장
let _ = UserDefaults.standard.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNzMyNzIyMzc1LCJleHAiOjE3MzI4MDg3NzV9.6gcH_Dwa5gGi9hYDIAvsKosJBoij93Na9oxjfGlAb8g", forKey: "token")
      
    NavigationView {
        RoomSelectionView(selectedRoom: .constant(nil))
    }
}
