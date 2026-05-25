import SwiftUI

struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var sortOrder: Int = 0
    var colorName: String = "blue"
    var dueDate: Date? = nil
    var tags: [String] = []

    static let presetTags = ["工作", "个人", "学习", "健康"]

    var color: Color {
        Color.colorFromName(colorName)
    }

    enum DueStatus {
        case overdue
        case today
        case upcoming
        case none
    }

    var dueStatus: DueStatus {
        guard let due = dueDate else { return .none }
        let cal = Calendar.current
        if due < cal.startOfDay(for: Date()) { return .overdue }
        if cal.isDateInToday(due) { return .today }
        return .upcoming
    }

    var dueDateString: String? {
        guard let due = dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        switch dueStatus {
        case .overdue, .today:
            formatter.dateFormat = "HH:mm"
        default:
            formatter.dateFormat = "M月d日 HH:mm"
        }
        return formatter.string(from: due)
    }

    static let availableColors: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("orange", .orange),
        ("green", .green),
        ("purple", .purple),
        ("pink", .pink),
        ("teal", .teal),
    ]
}

extension Color {
    static func colorFromName(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "orange": return .orange
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        default: return .blue
        }
    }
}
