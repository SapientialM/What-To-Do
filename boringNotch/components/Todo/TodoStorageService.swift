import Foundation

struct TodoStorageService {
    static let shared = TodoStorageService()

    private var appDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = appSupport.appendingPathComponent(Bundle.main.bundleIdentifier ?? "boringNotch", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private var todosURL: URL {
        appDirectory.appendingPathComponent("todos.json")
    }

    func loadTodos() -> [TodoItem] {
        guard FileManager.default.fileExists(atPath: todosURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: todosURL)
            return try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            print("Failed to load todos: \(error)")
            return []
        }
    }

    func saveTodos(_ todos: [TodoItem]) throws {
        let data = try JSONEncoder().encode(todos)
        try data.write(to: todosURL, options: .atomic)
    }
}
