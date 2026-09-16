import SwiftUI

struct WidgetView: View {
    @ObservedObject var monitor: GPUMonitor
    @ObservedObject var windowState: WidgetWindowState
    @State private var hovering = false

    var body: some View {
        ZStack(alignment: .top) {
            SpeedometerView(
                utilization: monitor.utilization,
                memoryPercent: monitor.memoryPercent,
                memoryUsedGB: monitor.memoryUsedGB,
                gpuName: monitor.gpuName
            )
            .padding(.top, 16 * windowState.size.scale)
            .padding(.horizontal, 4 * windowState.size.scale)
            .padding(.bottom, 4 * windowState.size.scale)
            .animation(.interpolatingSpring(stiffness: 140, damping: 16), value: monitor.utilization)
            .animation(.interpolatingSpring(stiffness: 140, damping: 16), value: monitor.memoryPercent)

            header
                .padding(.horizontal, 20 * windowState.size.scale)
                .padding(.top, 10 * windowState.size.scale)
        }
        .frame(width: windowState.windowSize.width, height: windowState.windowSize.height)
        .background(Color.clear)
        .onHover { hovering = $0 }
    }

    private var controlSize: CGFloat {
        max(22, 26 * windowState.size.scale)
    }

    private var header: some View {
        HStack(spacing: 8 * windowState.size.scale) {
            Text("GPU")
                .font(.system(size: max(9, 11 * windowState.size.scale), weight: .semibold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.8))
                .shadow(color: .black.opacity(0.85), radius: 2, y: 1)

            Spacer()

            HStack(spacing: 8 * windowState.size.scale) {
                Button {
                    windowState.presentSettingsMenu()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: max(12, 14 * windowState.size.scale), weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: controlSize, height: controlSize)
                        .background(controlBackground)
                }
                .buttonStyle(.plain)
                .help("Settings")

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: max(10, 11 * windowState.size.scale), weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: controlSize, height: controlSize)
                        .background(controlBackground)
                }
                .buttonStyle(.plain)
                .help("Quit GPU Watch")
            }
        }
        .opacity(1)
    }

    private var controlBackground: some View {
        Circle()
            .fill(Color.black.opacity(hovering ? 0.55 : 0.4))
            .overlay(Circle().stroke(Color.white.opacity(0.28), lineWidth: 1))
    }
}
