import Foundation

struct ChatStorageService {
    static let shared = ChatStorageService()

    private var appDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent(Bundle.main.bundleIdentifier ?? "boringNotch", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private var chatURL: URL {
        appDirectory.appendingPathComponent("chat.json")
    }

    func loadChatMessages() -> [ChatMessage] {
        guard FileManager.default.fileExists(atPath: chatURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: chatURL)
            let all = try JSONDecoder().decode([ChatMessage].self, from: data)
            return Array(all.suffix(50))
        } catch {
            print("Failed to load chat: \(error)")
            return []
        }
    }

    func saveChatMessages(_ messages: [ChatMessage]) throws {
        let recent = Array(messages.suffix(50))
        let data = try JSONEncoder().encode(recent)
        try data.write(to: chatURL, options: .atomic)
    }
}
