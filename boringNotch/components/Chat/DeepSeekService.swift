import Foundation
import Defaults

enum DeepSeekError: LocalizedError {
    case invalidURL
    case networkError(String)
    case httpError(Int, String)
    case parseError(String)
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API endpoint URL"
        case .networkError(let msg): return "Network error: \(msg)"
        case .httpError(let code, let msg): return "HTTP \(code): \(msg)"
        case .parseError(let msg): return "Parse error: \(msg)"
        case .missingAPIKey: return "API key not configured"
        }
    }
}

struct DeepSeekService {
    func sendMessage(messages: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await self.streamRequest(messages: messages, continuation: continuation)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func streamRequest(
        messages: [ChatMessage],
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let apiKey = Defaults[.deepSeekAPIKey]
        guard !apiKey.isEmpty else {
            throw DeepSeekError.missingAPIKey
        }

        guard let url = URL(string: Defaults[.deepSeekEndpoint]) else {
            throw DeepSeekError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let apiMessages: [[String: String]] = messages.map { msg in
            ["role": msg.role.rawValue, "content": msg.content]
        }

        let body: [String: Any] = [
            "model": Defaults[.deepSeekModel],
            "messages": apiMessages,
            "stream": true,
            "temperature": 0.7,
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (bytes, response) = try await URLSession.shared.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DeepSeekError.networkError("Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            var errorBody = ""
            for try await chunk in bytes.lines {
                errorBody += chunk
            }
            throw DeepSeekError.httpError(httpResponse.statusCode, errorBody)
        }

        for try await line in bytes.lines {
            guard line.hasPrefix("data: ") else { continue }
            let dataStr = String(line.dropFirst(6))
            if dataStr == "[DONE]" {
                return
            }
            if let data = dataStr.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let delta = choices.first?["delta"] as? [String: Any],
               let content = delta["content"] as? String {
                continuation.yield(content)
            }
        }
    }
}
