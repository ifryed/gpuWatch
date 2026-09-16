import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    let monitor = GPUMonitor()
    let windowState = WidgetWindowState()
    private var widgetWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        monitor.start()
        showWidgetWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowState.isVisible = true
        return false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func showWidgetWindow() {
        let size = windowState.windowSize
        let window = WidgetWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.isReleasedWhenClosed = true
        window.title = "GPU Watch"
        window.setFrameAutosaveName("GPUWatchWidget")

        let hosting = TransparentHostingView(
            rootView: WidgetView(monitor: monitor, windowState: windowState)
                .preferredColorScheme(.dark)
        )
        window.contentView = hosting

        if !window.setFrameUsingName("GPUWatchWidget") {
            if let screen = NSScreen.main {
                let frame = screen.visibleFrame
                let size = window.frame.size
                window.setFrameOrigin(
                    NSPoint(
                        x: frame.maxX - size.width - 24,
                        y: frame.maxY - size.height - 24
                    )
                )
            }
        }

        widgetWindow = window
        windowState.attach(window)
    }
}

private final class WidgetWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

private final class TransparentHostingView<Content: View>: NSHostingView<Content> {
    override var isOpaque: Bool { false }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        wantsLayer = true
        layer?.isOpaque = false
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        super.hitTest(point)
    }
}
