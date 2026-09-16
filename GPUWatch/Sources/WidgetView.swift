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
            .padding(4)
            .animation(.interpolatingSpring(stiffness: 140, damping: 16), value: monitor.utilization)
            .animation(.interpolatingSpring(stiffness: 140, damping: 16), value: monitor.memoryPercent)

            header
                .padding(.horizontal, 10)
                .padding(.top, 4)
        }
        .frame(width: 300, height: 318)
        .background(Color.clear)
        .onHover { hovering = $0 }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("GPU")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.8))
                .shadow(color: .black.opacity(0.85), radius: 2, y: 1)

            Spacer()

            Button {
                windowState.alwaysOnTop.toggle()
            } label: {
                Image(systemName: windowState.alwaysOnTop ? "pin.fill" : "pin")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(windowState.alwaysOnTop ? Color.orange : Color.white.opacity(0.85))
                    .frame(width: 26, height: 26)
                    .background(Color.black.opacity(hovering ? 0.35 : 0.18), in: Circle())
            }
            .buttonStyle(.plain)
            .help(windowState.alwaysOnTop ? "Keep in front: on" : "Keep in front: off")

            Button {
                windowState.isVisible = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 26, height: 26)
                    .background(Color.black.opacity(hovering ? 0.35 : 0.18), in: Circle())
            }
            .buttonStyle(.plain)
            .help("Hide widget")
        }
        .opacity(hovering ? 1 : 0.9)
    }
}
