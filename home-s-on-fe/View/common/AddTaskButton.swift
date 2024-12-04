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
        }
    }
}


#Preview {
    let viewModel = TaskViewModel() // 예시로 ViewModel 생성
    let houseId = 1 // 예시로 houseId 설정
    ZStack {
        Color.white.edgesIgnoringSafeArea(.all) // 배경색 추가
        AddTaskButton(isShowingAddTask: .constant(false), viewModel: viewModel, houseId: houseId) // 필요한 매개변수 전달
    }
}
