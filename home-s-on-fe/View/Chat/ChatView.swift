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
            ScrollViewReader { scrollViewProxy in
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
                            .id(chat.id) // 각 메시지에 고유 ID 설정
                        }
                    }
                    .padding()
                }
                .onChange(of: chatVM.chatHistory) { _ in
                    scrollToBottom(scrollViewProxy: scrollViewProxy)
                }
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
    
    private func scrollToBottom(scrollViewProxy: ScrollViewProxy) {
        if let lastMessage = chatVM.chatHistory.last {
            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

#Preview {
    let chatVM = ChatViewModel()
    ChatView().environmentObject(chatVM)
}
