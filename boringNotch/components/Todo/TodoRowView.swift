import SwiftUI

private let cardBg = Color(red: 20/255, green: 20/255, blue: 20/255)

struct TodoRowView: View {
    let title: String
    let isCompleted: Bool
    let color: Color
    let isFirst: Bool
    let isLast: Bool
    let dueDate: Date?
    let dueStatus: TodoItem.DueStatus
    let dueDateString: String?
    let tags: [String]
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onChangeColor: (String) -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onSetDueDate: (Date?) -> Void
    let onToggleTag: (String) -> Void

    @State private var isHovered: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            TimelineDot(color: color, isCompleted: isCompleted)
                .background(Color.black)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, design: .rounded))
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .gray : .white.opacity(0.9))

                HStack(spacing: 4) {
                    if let dueStr = dueDateString {
                        Text(dueStr)
                            .font(.system(size: 8, design: .rounded))
                            .foregroundColor(dueColor)
                    }
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 7, design: .rounded))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.white.opacity(0.06))
                            )
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.leading, 8)
            .padding(.vertical, 3)

            Spacer()

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 1)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? cardBg : .clear)
        )
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .onHover { hovering in
            withAnimation(.smooth(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("编辑", systemImage: "pencil")
            }
            Divider()
            Button(action: onMoveUp) {
                Label("上移", systemImage: "arrow.up")
            }.disabled(isFirst)
            Button(action: onMoveDown) {
                Label("下移", systemImage: "arrow.down")
            }.disabled(isLast)
            Divider()
            Button(action: onToggle) {
                Label(isCompleted ? "标记未完成" : "标记完成", systemImage: isCompleted ? "circle" : "checkmark.circle")
            }
            Divider()
            Menu("标签") {
                ForEach(TodoItem.presetTags, id: \.self) { tag in
                    Button(action: { onToggleTag(tag) }) {
                        if tags.contains(tag) { Label(tag, systemImage: "checkmark") } else { Text(tag) }
                    }
                }
            }
            Menu("截止日期") {
                Button(action: { onSetDueDate(Calendar.current.startOfDay(for: Date())) }) {
                    Label("今天", systemImage: "clock")
                }
                Button(action: {
                    let t = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                    onSetDueDate(Calendar.current.startOfDay(for: t))
                }) { Label("明天", systemImage: "sunrise") }
                Button(action: {
                    let w = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
                    onSetDueDate(Calendar.current.startOfDay(for: w))
                }) { Label("下周", systemImage: "calendar") }
                if dueDate != nil {
                    Divider()
                    Button(action: { onSetDueDate(nil) }) { Label("清除截止日期", systemImage: "xmark") }
                }
            }
            Menu("更改颜色") {
                ForEach(TodoItem.availableColors, id: \.name) { item in
                    Button(action: { onChangeColor(item.name) }) {
                        Label(item.name, systemImage: "circle.fill").foregroundColor(item.color)
                    }
                }
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("删除", systemImage: "trash")
            }
        }
    }

    private var dueColor: Color {
        if isCompleted { return .gray }
        switch dueStatus {
        case .overdue: return .red
        case .today: return .orange
        case .upcoming: return .gray
        case .none: return .gray
        }
    }
}
