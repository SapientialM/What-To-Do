import SwiftUI
import Defaults

@MainActor
class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()

    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isStreaming: Bool = false
    @Published var errorMessage: String?

    private let deepSeekService = DeepSeekService()
    private let storage = ChatStorageService.shared

    private init() {
        let saved = storage.loadChatMessages()
        if saved.isEmpty {
            messages.append(ChatMessage(
                role: .assistant,
                content: "你好！我可以帮你创建任务。试试说「帮我创建一个买菜的任务」。"
            ))
        } else {
            messages = saved
        }
    }

    func sendMessage() async {
        let trimmed = currentInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !isStreaming else { return }

        currentInput = ""
        errorMessage = nil

        let userMessage = ChatMessage(role: .user, content: trimmed)
        messages.append(userMessage)
        saveChat()

        let apiKey = Defaults[.deepSeekAPIKey]
        guard !apiKey.isEmpty else {
            messages.append(ChatMessage(role: .assistant, content: "请先在设置中配置 DeepSeek API 密钥。"))
            saveChat()
            return
        }

        var apiMessages: [ChatMessage] = [
            ChatMessage(role: .system, content: Defaults[.aiSystemPrompt])
        ]
        apiMessages.append(contentsOf: messages)

        isStreaming = true
        let assistantMessage = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMessage)

        var fullResponse = ""

        do {
            let stream = deepSeekService.sendMessage(messages: apiMessages)

            for try await chunk in stream {
                fullResponse += chunk
                if let lastIndex = messages.indices.last {
                    messages[lastIndex].content = fullResponse
                }
            }

            let actions = parseActions(from: fullResponse)
            for action in actions {
                await executeAction(action)
            }
            saveChat()
        } catch {
            if let lastIndex = messages.indices.last, messages[lastIndex].content.isEmpty {
                messages.remove(at: lastIndex)
            }
            errorMessage = error.localizedDescription
            messages.append(ChatMessage(
                role: .assistant,
                content: "出错了：\(error.localizedDescription)"
            ))
            saveChat()
        }

        isStreaming = false
    }

    private func saveChat() {
        do {
            try storage.saveChatMessages(messages)
        } catch {
            print("Failed to save chat: \(error)")
        }
    }

    // MARK: - Action Parsing

    private func parseActions(from text: String) -> [ChatAction] {
        guard let jsonStart = text.range(of: "```json"),
              let jsonEnd = text.range(of: "```", range: jsonStart.upperBound..<text.endIndex) else {
            return [.reply(text: text)]
        }

        let jsonString = String(text[jsonStart.upperBound..<jsonEnd.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8),
              let response = try? JSONDecoder().decode(ChatActionResponse.self, from: jsonData) else {
            return [.reply(text: text)]
        }

        return response.actions.compactMap { item in
            switch item.type {
            case "create_todo":
                return .createTodo(title: item.title)
            case "create_event":
                let startDate: Date?
                if let startStr = item.start {
                    startDate = Self.parseDate(startStr)
                } else {
                    startDate = nil
                }
                return .createEvent(
                    title: item.title,
                    startDate: startDate,
                    durationMinutes: item.durationMinutes ?? 60
                )
            default:
                return nil
            }
        }
    }

    // MARK: - Action Execution

    private func executeAction(_ action: ChatAction) async {
        switch action {
        case .createTodo(let title):
            TodoManager.shared.addTodoFromAI(title: title)
            messages.append(ChatMessage(
                role: .assistant,
                content: "已创建任务：「\(title)」"
            ))

        case .createEvent(let title, let startDate, let durationMinutes):
            messages.append(ChatMessage(
                role: .assistant,
                content: "日程创建功能暂不支持。"
            ))

        case .reply:
            break
        }
    }

    // MARK: - Test Connection

    func testConnection() async -> (Bool, String) {
        let apiKey = Defaults[.deepSeekAPIKey]
        guard !apiKey.isEmpty else {
            return (false, "请先配置 API 密钥")
        }

        guard let url = URL(string: Defaults[.deepSeekEndpoint]) else {
            return (false, "无效的 API 端点 URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": Defaults[.deepSeekModel],
            "messages": [["role": "user", "content": "Hi"]],
            "max_tokens": 10,
            "stream": false,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return (false, "无效的服务器响应")
            }

            if httpResponse.statusCode == 200 {
                return (true, "连接成功！")
            } else {
                let body = String(data: data, encoding: .utf8) ?? ""
                return (false, "HTTP \(httpResponse.statusCode): \(body.prefix(100))")
            }
        } catch {
            return (false, error.localizedDescription)
        }
    }

    // MARK: - Date Parsing

    private static func parseDate(_ string: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: string) { return date }
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: string) { return date }

        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        localFormatter.timeZone = TimeZone.current
        if let date = localFormatter.date(from: string) { return date }

        localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return localFormatter.date(from: string)
    }
}
