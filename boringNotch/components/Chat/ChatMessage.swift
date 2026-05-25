import Foundation

struct ChatMessage: Identifiable, Equatable, Codable {
    enum Role: String, Codable {
        case user
        case assistant
        case system
    }

    var id: UUID = UUID()
    let role: Role
    var content: String
    let timestamp: Date = Date()
}
