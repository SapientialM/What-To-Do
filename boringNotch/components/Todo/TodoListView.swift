import SwiftUI

struct TodoListView: View {
    @ObservedObject var todoManager = TodoManager.shared
    @FocusState private var isInputFocused: Bool

    @State private var editingTodo: TodoItem?
    @State private var editText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Search + filter bar
            HStack(spacing: 4) {
                HStack(spacing: 3) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                    TextField("搜索...", text: $todoManager.searchText)
                        .font(.system(size: 10, design: .rounded))
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.06))
                )

                ForEach(FilterStatus.allCases, id: \.self) { status in
                    Button(action: { todoManager.filterStatus = status }) {
                        Text(status.rawValue)
                            .font(.system(size: 9, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(todoManager.filterStatus == status
                                          ? Color(nsColor: .secondarySystemFill)
                                          : .clear)
                            )
                            .foregroundColor(todoManager.filterStatus == status ? .white : .gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            // Tag chips
            let counts = todoManager.activeTagCounts
            if counts.contains(where: { $0.count > 0 }) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(counts, id: \.tag) { item in
                            if item.count > 0 {
                                Button(action: {
                                    todoManager.selectedTag = (todoManager.selectedTag == item.tag) ? nil : item.tag
                                }) {
                                    Text("\(item.tag) \(item.count)")
                                        .font(.system(size: 8, design: .rounded))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(todoManager.selectedTag == item.tag
                                                      ? Color(nsColor: .secondarySystemFill)
                                                      : .white.opacity(0.06))
                                        )
                                        .foregroundColor(todoManager.selectedTag == item.tag ? .white : .gray)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 4)
            }

            let displayTodos = todoManager.filteredTodos

            if displayTodos.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.3))
                    Text(todoManager.todos.isEmpty ? "暂无任务" : "无匹配结果")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.gray)
                    if todoManager.todos.isEmpty {
                        Text("输入下方或让 AI 帮你创建")
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
                .padding(.vertical, 16)
            } else {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 1.5)
                        .padding(.leading, 20)

                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(Array(displayTodos.enumerated()), id: \.element.id) { index, todo in
                                TodoRowView(
                                    title: todo.title,
                                    isCompleted: todo.isCompleted,
                                    color: todo.color,
                                    isFirst: index == 0,
                                    isLast: index == displayTodos.count - 1,
                                    dueDate: todo.dueDate,
                                    dueStatus: todo.dueStatus,
                                    dueDateString: todo.dueDateString,
                                    tags: todo.tags,
                                    onToggle: { todoManager.toggleComplete(todo) },
                                    onDelete: { todoManager.deleteTodo(todo) },
                                    onEdit: { editingTodo = todo; editText = todo.title },
                                    onChangeColor: { todoManager.changeColor(todo, to: $0) },
                                    onMoveUp: { todoManager.moveUp(todo) },
                                    onMoveDown: { todoManager.moveDown(todo) },
                                    onSetDueDate: { todoManager.setDueDate(todo, to: $0) },
                                    onToggleTag: { todoManager.toggleTag(todo, tag: $0) }
                                )
                            }
                        }
                        .padding(.vertical, 4)
                        .animation(.smooth(duration: 0.2), value: displayTodos.map(\.id))
                    }
                }
                .frame(minHeight: 60)
            }

            // Add input
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.accentColor.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .frame(width: 20)

                TextField("添加任务...", text: $todoManager.newTodoText)
                    .font(.system(size: 11, design: .rounded))
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                    .onSubmit {
                        withAnimation(.smooth(duration: 0.2)) { todoManager.addTodo() }
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
        }
        .alert("编辑任务", isPresented: .constant(editingTodo != nil)) {
            TextField("任务标题", text: $editText)
            Button("确定") { if let t = editingTodo { todoManager.editTodoTitle(t, newTitle: editText) }; editingTodo = nil }
            Button("取消", role: .cancel) { editingTodo = nil }
        }
    }
}
