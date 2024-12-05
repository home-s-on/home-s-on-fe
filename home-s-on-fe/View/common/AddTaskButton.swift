//
//  AddTaskButton.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/28/24.
//

import SwiftUI

struct AddTaskButton: View {
    @State private var isShowingAddTask = false
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var houseId: Int = Int(UserDefaults.standard.string(forKey: "houseId") ?? "0") ?? 0
    @EnvironmentObject var triggerVM: TriggerViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isShowingAddTask = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isShowingAddTask) {
            AddTaskView(isPresented: $isShowingAddTask)
                .environmentObject(viewModel)  // viewModel을 전달
                .presentationDetents([.large])
                .environmentObject(TriggerViewModel())
        }
    }
}



#Preview {
    ZStack {
        Color.white.edgesIgnoringSafeArea(.all) // 배경색 추가
        AddTaskButton ()
    }
}
