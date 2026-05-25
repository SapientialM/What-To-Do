import SwiftUI

private let cardBg = Color(red: 20/255, green: 20/255, blue: 20/255)

struct ChatMessageBubble: View {
    let content: String
    let isUser: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            if isUser { Spacer(minLength: 20) }

            Text(content)
                .font(.system(size: 11, design: .rounded))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isUser ? Color.accentColor : cardBg)
                )
                .foregroundColor(isUser ? .white : .white.opacity(0.85))

            if !isUser { Spacer(minLength: 20) }
        }
        .padding(.horizontal, 12)
    }
}
