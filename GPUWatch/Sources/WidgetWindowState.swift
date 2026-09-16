import AppKit
import SwiftUI

enum WidgetSize: String, CaseIterable, Identifiable {
    case normal
    case small
    case mini

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal: return "Normal"
        case .small: return "Small"
        case .mini: return "Mini"
        }
    }

    var scale: CGFloat {
        switch self {
        case .normal: return 1.0
        case .small: return 0.75
        case .mini: return 0.55
        }
    }
}

@MainActor
final class WidgetWindowState: NSObject, ObservableObject {
    static let baseSize = CGSize(width: 300, height: 318)

    @Published var alwaysOnTop: Bool {
        didSet {
            UserDefaults.standard.set(alwaysOnTop, forKey: Self.alwaysOnTopKey)
            applyLevel()
        }
    }

    @Published var size: WidgetSize {
        didSet {
            UserDefaults.standard.set(size.rawValue, forKey: Self.sizeKey)
            applyFrame()
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

    var windowSize: CGSize {
        CGSize(
            width: Self.baseSize.width * size.scale,
            height: Self.baseSize.height * size.scale
        )
    }

    private weak var window: NSWindow?
    private static let alwaysOnTopKey = "alwaysOnTop"
    private static let sizeKey = "widgetSize"

    override init() {
        if UserDefaults.standard.object(forKey: Self.alwaysOnTopKey) == nil {
            alwaysOnTop = true
        } else {
            alwaysOnTop = UserDefaults.standard.bool(forKey: Self.alwaysOnTopKey)
        }

        if let raw = UserDefaults.standard.string(forKey: Self.sizeKey),
           let saved = WidgetSize(rawValue: raw) {
            size = saved
        } else {
            size = .normal
        }
        super.init()
    }

    func attach(_ window: NSWindow) {
        self.window = window
        applyLevel()
        applyFrame()
        if isVisible {
            window.orderFrontRegardless()
        }
    }

    func toggleVisibility() {
        isVisible.toggle()
    }

    @objc func togglePinned() {
        alwaysOnTop.toggle()
    }

    func presentSettingsMenu() {
        guard let window, let contentView = window.contentView else { return }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)

        let menu = NSMenu()
        let pinItem = NSMenuItem(
            title: alwaysOnTop ? "Unpin" : "Pin",
            action: #selector(togglePinned),
            keyEquivalent: ""
        )
        pinItem.target = self
        pinItem.image = NSImage(systemSymbolName: alwaysOnTop ? "pin.slash" : "pin", accessibilityDescription: nil)
        menu.addItem(pinItem)
        menu.addItem(.separator())

        let sizeMenu = NSMenu()
        for widgetSize in WidgetSize.allCases {
            let item = NSMenuItem(
                title: widgetSize.title,
                action: #selector(selectSize(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = widgetSize.rawValue
            item.state = size == widgetSize ? .on : .off
            sizeMenu.addItem(item)
        }
        let sizeItem = NSMenuItem(title: "Size", action: nil, keyEquivalent: "")
        sizeItem.submenu = sizeMenu
        menu.addItem(sizeItem)

        let point = NSPoint(x: contentView.bounds.maxX - 36, y: contentView.bounds.maxY - 30)
        menu.popUp(positioning: nil, at: point, in: contentView)
    }

    @objc private func selectSize(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let value = WidgetSize(rawValue: raw) else { return }
        size = value
    }

    private func applyLevel() {
        guard let window else { return }
        window.level = alwaysOnTop ? .floating : .normal
        if alwaysOnTop {
            window.orderFrontRegardless()
        }
    }

    private func applyFrame() {
        guard let window else { return }
        let newSize = windowSize
        var frame = window.frame
        if frame.size == .zero {
            frame.size = newSize
        } else {
            let top = frame.maxY
            let trailing = frame.maxX
            frame.size = newSize
            frame.origin.x = trailing - newSize.width
            frame.origin.y = top - newSize.height
        }
        window.setFrame(frame, display: true, animate: true)
    }
}
