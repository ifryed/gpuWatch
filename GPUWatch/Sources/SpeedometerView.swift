import SwiftUI

struct SpeedometerView: View {
    var utilization: Double
    var memoryPercent: Double
    var memoryUsedGB: Double
    var gpuName: String

    private var utilValue: Double { min(100, max(0, utilization)) }
    private var vramValue: Double { min(100, max(0, memoryPercent)) }

    private var utilGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.18, green: 0.86, blue: 0.62), location: 0.00),
                .init(color: Color(red: 0.96, green: 0.78, blue: 0.22), location: 0.62),
                .init(color: Color(red: 1.00, green: 0.38, blue: 0.22), location: 1.00)
            ]),
            center: .center,
            startAngle: .degrees(135),
            endAngle: .degrees(405)
        )
    }

    private var vramGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.28, green: 0.72, blue: 1.00), location: 0.00),
                .init(color: Color(red: 0.45, green: 0.42, blue: 1.00), location: 0.62),
                .init(color: Color(red: 0.92, green: 0.32, blue: 0.95), location: 1.00)
            ]),
            center: .center,
            startAngle: .degrees(135),
            endAngle: .degrees(405)
        )
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let outerSize = size * 0.68
            let innerSize = size * 0.50
            let outerWidth = size * 0.052
            let innerWidth = size * 0.042

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.18, green: 0.19, blue: 0.22),
                                Color(red: 0.06, green: 0.06, blue: 0.08)
                            ],
                            center: .center,
                            startRadius: size * 0.04,
                            endRadius: size * 0.49
                        )
                    )
                    .frame(width: size * 0.98, height: size * 0.98)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )

                ticks(size: size, center: center, radius: size * 0.37)

                GaugeArc(value: 100)
                    .stroke(Color.black.opacity(0.38), style: StrokeStyle(lineWidth: outerWidth, lineCap: .round))
                    .frame(width: outerSize, height: outerSize)
                GaugeArc(value: utilValue)
                    .stroke(utilGradient, style: StrokeStyle(lineWidth: outerWidth, lineCap: .round))
                    .frame(width: outerSize, height: outerSize)

                GaugeArc(value: 100)
                    .stroke(Color.black.opacity(0.38), style: StrokeStyle(lineWidth: innerWidth, lineCap: .round))
                    .frame(width: innerSize, height: innerSize)
                GaugeArc(value: vramValue)
                    .stroke(vramGradient, style: StrokeStyle(lineWidth: innerWidth, lineCap: .round))
                    .frame(width: innerSize, height: innerSize)

                Needle(value: utilValue)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 1.0, green: 0.32, blue: 0.22)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: size * 0.046, height: size * 0.33)
                    .rotationEffect(.degrees(-135 + 270 * utilValue / 100), anchor: .bottom)
                    .offset(y: -size * 0.165)
                    .shadow(color: .black.opacity(0.55), radius: 2, y: 1)

                Needle(value: vramValue)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.35, green: 0.55, blue: 1.0)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: size * 0.036, height: size * 0.23)
                    .rotationEffect(.degrees(-135 + 270 * vramValue / 100), anchor: .bottom)
                    .offset(y: -size * 0.115)
                    .shadow(color: .black.opacity(0.45), radius: 1.5, y: 1)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.92), Color(white: 0.18)],
                            center: .center,
                            startRadius: 1,
                            endRadius: size * 0.055
                        )
                    )
                    .frame(width: size * 0.11, height: size * 0.11)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 3, y: 1)

                VStack(spacing: size * 0.008) {
                    Text("\(Int(utilValue.rounded()))%")
                        .font(.system(size: size * 0.12, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text(String(format: "%.2f GB", memoryUsedGB))
                        .font(.system(size: size * 0.058, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color(red: 0.55, green: 0.78, blue: 1.0))
                    HStack(spacing: size * 0.04) {
                        legendDot(color: Color(red: 0.18, green: 0.86, blue: 0.62), title: "UTIL", size: size)
                        legendDot(color: Color(red: 0.28, green: 0.72, blue: 1.00), title: "VRAM", size: size)
                    }
                    Text(gpuName)
                        .font(.system(size: size * 0.04, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .shadow(color: .black.opacity(0.85), radius: 4, y: 1)
                .position(x: center.x, y: center.y + size * 0.28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("GPU usage")
        .accessibilityValue("\(Int(utilValue.rounded())) percent utilization, \(String(format: "%.2f", memoryUsedGB)) gigabytes VRAM")
    }

    private func legendDot(color: Color, title: String, size: CGFloat) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: size * 0.028, height: size * 0.028)
            Text(title)
                .font(.system(size: size * 0.038, weight: .semibold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.85))
        }
        .shadow(color: .black.opacity(0.8), radius: 2, y: 1)
    }

    private func ticks(size: CGFloat, center: CGPoint, radius: CGFloat) -> some View {
        Canvas { context, _ in
            for i in 0...20 {
                let t = Double(i) / 20.0
                let angle = Angle.degrees(135 + 270 * t).radians
                let isMajor = i.isMultiple(of: 2)
                let inner = radius
                let outer = radius + (isMajor ? size * 0.032 : size * 0.016)
                var path = Path()
                path.move(to: CGPoint(
                    x: center.x + CGFloat(cos(angle)) * inner,
                    y: center.y + CGFloat(sin(angle)) * inner
                ))
                path.addLine(to: CGPoint(
                    x: center.x + CGFloat(cos(angle)) * outer,
                    y: center.y + CGFloat(sin(angle)) * outer
                ))
                context.stroke(
                    path,
                    with: .color(.white.opacity(isMajor ? 0.8 : 0.35)),
                    lineWidth: isMajor ? 1.6 : 1
                )

                if isMajor {
                    let label = "\(i * 5)"
                    let point = CGPoint(
                        x: center.x + CGFloat(cos(angle)) * (radius + size * 0.06),
                        y: center.y + CGFloat(sin(angle)) * (radius + size * 0.06)
                    )
                    let halo = Text(label)
                        .font(.system(size: size * 0.038, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.75))
                    for dx in [-1.0, 0.0, 1.0] {
                        for dy in [-1.0, 0.0, 1.0] where dx != 0 || dy != 0 {
                            context.draw(halo, at: CGPoint(x: point.x + dx, y: point.y + dy), anchor: .center)
                        }
                    }
                    let text = Text(label)
                        .font(.system(size: size * 0.038, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    context.draw(text, at: point, anchor: .center)
                }
            }
        }
    }
}

private struct GaugeArc: Shape {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = Angle.degrees(135)
        let end = Angle.degrees(135 + 270 * min(100, max(0, value)) / 100)
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: start,
            endAngle: end,
            clockwise: false
        )
        return path
    }
}

private struct Needle: Shape {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let hub = CGPoint(x: rect.midX, y: rect.maxY)
        path.move(to: CGPoint(x: rect.midX - rect.width * 0.38, y: rect.maxY - rect.height * 0.1))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.38, y: rect.maxY - rect.height * 0.1))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX - rect.width * 0.38, y: rect.maxY - rect.height * 0.1),
            control: hub
        )
        path.closeSubpath()
        return path
    }
}
