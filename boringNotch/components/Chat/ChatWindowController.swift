import AppKit
import SwiftUI

class ChatWindowController: NSWindowController {
    static let shared = ChatWindowController()

    private var chatViewModel = ChatViewModel.shared

    private init() {
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 600),
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel, .utilityWindow, .hudWindow],
            backing: .buffered,
            defer: false
        )

        super.init(window: window)

        setupWindow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow() {
        guard let window = window else { return }

        window.title = "AI Assistant"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .black
        window.appearance = NSAppearance(named: .darkAqua)
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 300, height: 400)

        window.contentView = NSHostingView(
            rootView: ChatView(chatViewModel: chatViewModel)
                .preferredColorScheme(.dark)
        )

        window.delegate = self
    }

    func showWindow() {
        window?.orderFrontRegardless()
        window?.makeKeyAndOrderFront(nil)
        window?.center()
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension ChatWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
}
