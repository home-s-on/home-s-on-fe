//
//  ChatView.swift
//  home-s-on-fe
//
//  Created by 정송희 on 12/10/24.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var chatVM : ChatViewModel
    @State private var newMessage = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(chatVM.chatHistory) { chat in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("You:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(chat.userMessage)
                                .padding(10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            
                            Text("Assistant:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(chat.assistantResponse)
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .onAppear {
            chatVM.getChat()
        }
    }
    
    private func sendMessage() {
        let messageToSend = newMessage
        newMessage = ""
        chatVM.sendChat(userMessage: messageToSend)
    }
}

#Preview {
    let chatVM = ChatViewModel()
    ChatView().environmentObject(chatVM)
}
