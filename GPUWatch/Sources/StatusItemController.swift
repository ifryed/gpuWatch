import AppKit

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let windowState: WidgetWindowState

    init(monitor: GPUMonitor, windowState: WidgetWindowState) {
        self.windowState = windowState
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "gauge.with.needle", accessibilityDescription: "GPU Watch")
            image?.isTemplate = true
            button.image = image
            button.imagePosition = .imageOnly
            button.title = ""
            button.toolTip = "GPU Watch"
        }

        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        windowState.populateSettings(menu, includeQuit: true)
    }
}
