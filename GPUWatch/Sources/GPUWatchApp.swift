import SwiftUI

@main
struct GPUWatchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenu(windowState: appDelegate.windowState)
        } label: {
            MenuBarLabel(monitor: appDelegate.monitor)
        }
    }
}

private struct MenuBarMenu: View {
    @ObservedObject var windowState: WidgetWindowState

    var body: some View {
        Button(windowState.isVisible ? "Hide Widget" : "Show Widget") {
            windowState.toggleVisibility()
        }
        Toggle("Keep in Front", isOn: $windowState.alwaysOnTop)
        Divider()
        Menu("Size") {
            ForEach(WidgetSize.allCases) { size in
                Button {
                    windowState.size = size
                } label: {
                    if windowState.size == size {
                        Label(size.title, systemImage: "checkmark")
                    } else {
                        Text(size.title)
                    }
                }
            }
        }
        Divider()
        Button("Quit GPU Watch") {
            NSApp.terminate(nil)
        }
    }
}

private struct MenuBarLabel: View {
    @ObservedObject var monitor: GPUMonitor

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "gauge.with.needle")
            Text("\(Int(monitor.utilization.rounded()))%")
                .monospacedDigit()
        }
    }
}
