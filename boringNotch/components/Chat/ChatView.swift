import SwiftUI

struct ChatView: View {
    @ObservedObject var chatViewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(chatViewModel.messages) { message in
                            ChatMessageBubble(
                                content: message.content,
                                isUser: message.role == .user
                            )
                            .id(message.id)
                        }

                        if chatViewModel.isStreaming {
                            HStack {
                                ChatMessageBubble(content: "...", isUser: false).opacity(0.4)
                                Spacer(minLength: 20)
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .onChange(of: chatViewModel.messages.count) { _, _ in
                    if let last = chatViewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onChange(of: chatViewModel.messages.last?.content) { _, _ in
                    if let last = chatViewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .frame(minHeight: 120)

            HStack(spacing: 4) {
                TextField("让 AI 帮你创建任务...", text: $chatViewModel.currentInput)
                    .font(.system(size: 11, design: .rounded))
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .disabled(chatViewModel.isStreaming)
                    .onSubmit { Task { await chatViewModel.sendMessage() } }

                Button(action: { Task { await chatViewModel.sendMessage() } }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .disabled(chatViewModel.currentInput.trimmingCharacters(in: .whitespaces).isEmpty || chatViewModel.isStreaming)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
        }
    }
}
