//
//  TaskListView.swift
//  home-s-on-fe
//
//  Created by 안혜지 on 11/22/24.
//

import SwiftUI

struct TaskListView: View {
    @State private var tasks: [Task] = [] // 할일 목록
    @State private var isLoading = true
    @State private var errorMessage: String?

    let houseId: Int // houseId를 외부에서 받아옵니다.

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List(tasks) { task in
                        TaskRowView(task: task) // 각 할일에 대해 TaskRowView 사용
                    }
                }
            }
            .navigationTitle("할일 목록")
            .onAppear(perform: loadTasks)
        }
    }

    private func loadTasks() {
        guard let url = URL(string: "http://localhost:5001/api/tasks/house/\(houseId)") else {
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching tasks: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                    self.isLoading = false
                }
                return
            }

            do {
                let decodedTasks = try JSONDecoder().decode([Task].self, from: data)
                DispatchQueue.main.async {
                    self.tasks = decodedTasks
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error decoding tasks: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}
