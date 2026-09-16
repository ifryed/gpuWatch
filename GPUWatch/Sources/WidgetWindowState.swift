import AppKit
import SwiftUI

@MainActor
final class WidgetWindowState: ObservableObject {
    @Published var alwaysOnTop: Bool {
        didSet {
            UserDefaults.standard.set(alwaysOnTop, forKey: Self.alwaysOnTopKey)
            applyLevel()
        }
    }

    @Published var isVisible: Bool = true {
        didSet {
            if isVisible {
                window?.orderFrontRegardless()
            } else {
                window?.orderOut(nil)
            }
        }
    }

    private weak var window: NSWindow?
    private static let alwaysOnTopKey = "alwaysOnTop"

    init() {
        if UserDefaults.standard.object(forKey: Self.alwaysOnTopKey) == nil {
            alwaysOnTop = true
        } else {
            alwaysOnTop = UserDefaults.standard.bool(forKey: Self.alwaysOnTopKey)
        }
    }

    func attach(_ window: NSWindow) {
        self.window = window
        applyLevel()
        if isVisible {
            window.orderFrontRegardless()
        }
    }

    func toggleVisibility() {
        isVisible.toggle()
    }

    private func applyLevel() {
        guard let window else { return }
        window.level = alwaysOnTop ? .floating : .normal
        if alwaysOnTop {
            window.orderFrontRegardless()
        }
    }
}
