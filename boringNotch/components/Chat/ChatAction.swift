import Foundation

enum ChatAction: Equatable {
    case createTodo(title: String)
    case createEvent(title: String, startDate: Date?, durationMinutes: Int)
    case reply(text: String)
}

struct ChatActionResponse: Codable {
    let actions: [ActionItem]
}

struct ActionItem: Codable {
    let type: String
    let title: String
    let start: String?
    let durationMinutes: Int?
}
