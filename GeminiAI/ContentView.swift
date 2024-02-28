//
//  ContentView.swift
//  GeminiAI
//
//  Created by Aditya Ghorpade on 18/02/24.
//

import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    @State var textFieldText: String = ""
    @State var aiResponse: String = ""
    @State var chatMessages: [ChatMessage] = []
    
    func sendMessage() {
        aiResponse = ""
        let userMessage = textFieldText
        
        Task {
            do {
                chatMessages.append(ChatMessage(content: "gemini is typing...", sender: .model))
                
                let response = try await model.generateContent(userMessage)
                
                guard let text = response.text else {
                    return
                }
                
                aiResponse = text
                
                withAnimation {
                    chatMessages.removeLast()
                    chatMessages.append(ChatMessage(content: aiResponse, sender: .model))
                }
                
            } catch {
                aiResponse = "Something went wrong!\n\(error.localizedDescription)"
                chatMessages.removeLast()
                withAnimation {
                    chatMessages.append(ChatMessage(content: aiResponse , sender: .model))
                }
            }
        }
    }
    
    func messageView(message: ChatMessage) -> some View {
        HStack {
            if message.sender == .user { Spacer() }
            Text(message.content)
                .foregroundStyle(Color.white)
                .padding()
                .background(message.sender == .user ? Color.blue : Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            if message.sender == .model { Spacer() }
        }
    }
    
    var body: some View {
        VStack {
            Image("gemini_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .padding(.bottom, 10)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(chatMessages, id: \.id) { messages in
                        messageView(message: messages)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                }
                .rotationEffect(.degrees(180))
            }
            .background(Color.gray.opacity(0.2))
            .rotationEffect(.degrees(180))
            
            HStack {
                TextField("type here...", text: $textFieldText)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onSubmit {
                        if !textFieldText.isEmpty {
                            withAnimation {
                                chatMessages.append(ChatMessage(content: textFieldText, sender: .user))
                            }
                            sendMessage()
                        }
                        textFieldText = ""
                    }
                
                Button {
                    if !textFieldText.isEmpty {
                        withAnimation {
                            chatMessages.append(ChatMessage(content: textFieldText, sender: .user))
                        }
                        sendMessage()
                    }
                    textFieldText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 26))
                        .padding(.horizontal, 5)
                }
            }
            .padding()
        }
    }
}

struct ChatMessage: Identifiable{
    let id = UUID().uuidString
    let content: String
    let sender: MessageSender
}

enum MessageSender {
    case user, model
}



#Preview {
    ContentView()
}
