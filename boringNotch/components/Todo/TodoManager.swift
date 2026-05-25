import SwiftUI

enum FilterStatus: String, CaseIterable {
    case all = "全部"
    case active = "未完成"
    case completed = "已完成"

    var systemImage: String {
        switch self {
        case .all: return "list.bullet"
        case .active: return "circle"
        case .completed: return "checkmark.circle"
        }
    }
}

@MainActor
class TodoManager: ObservableObject {
    static let shared = TodoManager()

    @Published var todos: [TodoItem] = []
    @Published var newTodoText: String = ""
    @Published var searchText: String = ""
    @Published var filterStatus: FilterStatus = .all
    @Published var selectedTag: String? = nil

    private let storage = TodoStorageService.shared

    var filteredTodos: [TodoItem] {
        var result = todos

        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        switch filterStatus {
        case .all: break
        case .active: result = result.filter { !$0.isCompleted }
        case .completed: result = result.filter { $0.isCompleted }
        }

        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }

        return result
    }

    var activeTagCounts: [(tag: String, count: Int)] {
        let active = todos.filter { !$0.isCompleted }
        var counts: [String: Int] = [:]
        for item in active {
            for tag in item.tags {
                counts[tag, default: 0] += 1
            }
        }
        return TodoItem.presetTags.map { (tag: $0, count: counts[$0] ?? 0) }
    }

    private init() {
        loadTodos()
    }

    func loadTodos() {
        todos = storage.loadTodos()
    }

    private func save() {
        do {
            try storage.saveTodos(todos)
        } catch {
            print("Failed to save todos: \(error)")
        }
    }

    // MARK: - CRUD

    func addTodo() {
        let trimmed = newTodoText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let color = TodoItem.availableColors.randomElement()!
        let maxOrder = todos.map(\.sortOrder).max() ?? -1
        let item = TodoItem(
            title: trimmed,
            sortOrder: maxOrder + 1,
            colorName: color.name
        )
        todos.append(item)
        newTodoText = ""
        save()
    }

    func addTodoFromAI(title: String) {
        let color = TodoItem.availableColors.randomElement()!
        let maxOrder = todos.map(\.sortOrder).max() ?? -1
        let item = TodoItem(
            title: title,
            sortOrder: maxOrder + 1,
            colorName: color.name
        )
        todos.append(item)
        save()
    }

    func toggleComplete(_ item: TodoItem) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        todos[index].isCompleted.toggle()
        save()
    }

    func editTodoTitle(_ item: TodoItem, newTitle: String) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }),
              !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        todos[index].title = newTitle.trimmingCharacters(in: .whitespaces)
        save()
    }

    func deleteTodo(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
        save()
    }

    // MARK: - Reorder

    func moveUp(_ item: TodoItem) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }), index > 0 else { return }
        todos.swapAt(index, index - 1)
        for (i, _) in todos.enumerated() {
            todos[i].sortOrder = i
        }
        save()
    }

    func moveDown(_ item: TodoItem) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }), index < todos.count - 1 else { return }
        todos.swapAt(index, index + 1)
        for (i, _) in todos.enumerated() {
            todos[i].sortOrder = i
        }
        save()
    }

    // MARK: - Tags

    func toggleTag(_ item: TodoItem, tag: String) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        if let tagIndex = todos[index].tags.firstIndex(of: tag) {
            todos[index].tags.remove(at: tagIndex)
        } else {
            todos[index].tags.append(tag)
        }
        save()
    }

    func changeColor(_ item: TodoItem, to colorName: String) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        todos[index].colorName = colorName
        save()
    }

    func setDueDate(_ item: TodoItem, to date: Date?) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        todos[index].dueDate = date
        save()
    }
}
