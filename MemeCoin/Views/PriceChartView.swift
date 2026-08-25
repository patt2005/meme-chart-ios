import SwiftUI

struct PriceChartView: View {
    let priceList: [Double]
    let lineColor: Color

    @Binding var selectedPrice: Double
    @State private var trimValue: CGFloat = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showCrosshair: Bool = false

    private var minY: Double { priceList.min() ?? 0 }
    private var maxY: Double { priceList.max() ?? 0 }

    var body: some View {
        GeometryReader { geo in
            if priceList.count < 2 {
                Text("No chart data")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(white: 1, opacity: 0.3))
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            } else {
                let pts = buildPoints(in: geo.size)
                ZStack {
                    gradientFill(points: pts, size: geo.size)
                    linePath(points: pts)
                        .trim(from: 0, to: trimValue)
                        .stroke(
                            lineColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: lineColor.opacity(0.55), radius: 8)
                        .onAppear {
                            selectedPrice = priceList.last ?? 0
                            withAnimation(.linear(duration: 1.2)) { trimValue = 1 }
                        }

                    highLabel(pts: pts, size: geo.size)
                    lowLabel(pts: pts, size: geo.size)

                    if trimValue >= 0.99, let last = pts.last {
                        endpointDot(at: last)
                    }

                    if showCrosshair {
                        crosshair(offset: dragOffset, height: geo.size.height)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let stepW = geo.size.width / CGFloat(priceList.count - 1)
                            let idx = max(0, min(Int((value.location.x / stepW).rounded()), priceList.count - 1))
                            selectedPrice = priceList[idx]
                            withAnimation(.easeOut(duration: 0.08)) { showCrosshair = true }
                            dragOffset = CGSize(
                                width:  pts[idx].x - geo.size.width / 2,
                                height: pts[idx].y - geo.size.height / 2
                            )
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.2)) { showCrosshair = false }
                            selectedPrice = priceList.last ?? 0
                        }
                )
            }
        }
    }

    private func highLabel(pts: [CGPoint], size: CGSize) -> some View {
        let highY = pts.min(by: { $0.y < $1.y })?.y ?? 0
        let price = priceList.max() ?? 0
        return glassLabel("H \(formatPrice(price))")
            .position(x: size.width - 62, y: max(highY + 22, 26))
            .opacity(trimValue > 0.9 ? 1 : 0)
            .animation(.easeIn(duration: 0.3).delay(1.0), value: trimValue)
    }

    private func lowLabel(pts: [CGPoint], size: CGSize) -> some View {
        let lowY = pts.max(by: { $0.y < $1.y })?.y ?? size.height
        let price = priceList.min() ?? 0
        return glassLabel("L \(formatPrice(price))")
            .position(x: 62, y: min(lowY - 22, size.height - 26))
            .opacity(trimValue > 0.9 ? 1 : 0)
            .animation(.easeIn(duration: 0.3).delay(1.1), value: trimValue)
    }

    private func glassLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium).monospaced())
            .foregroundStyle(Color(white: 1, opacity: 0.7))
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 11)
                    .fill(Color(white: 1, opacity: 0.07))
                    .overlay(RoundedRectangle(cornerRadius: 11)
                        .stroke(Color(white: 1, opacity: 0.10), lineWidth: 1))
            )
    }

    private func endpointDot(at point: CGPoint) -> some View {
        ZStack {
            Circle()
                .fill(lineColor.opacity(0.16))
                .frame(width: 24, height: 24)
            Circle()
                .fill(lineColor)
                .frame(width: 10, height: 10)
        }
        .position(point)
    }

    private func crosshair(offset: CGSize, height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(white: 1, opacity: 0.25))
                .frame(width: 1, height: height)
            Circle()
                .fill(lineColor)
                .frame(width: 12, height: 12)
                .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 1.5))
                .shadow(color: lineColor.opacity(0.7), radius: 6)
                .offset(y: offset.height)
        }
        .offset(x: offset.width)
    }

    private func buildPoints(in size: CGSize) -> [CGPoint] {
        let total = max(priceList.count, 2)
        let stepW = size.width / CGFloat(total - 1)
        let range = maxY - minY == 0 ? 1 : maxY - minY
        let pad: CGFloat = 20
        return priceList.enumerated().map { i, val in
            CGPoint(
                x: stepW * CGFloat(i),
                y: pad + (1 - CGFloat((val - minY) / range)) * (size.height - pad * 2)
            )
        }
    }

    private func linePath(points: [CGPoint]) -> Path {
        Path { p in
            guard let first = points.first else { return }
            p.move(to: first)
            for pt in points.dropFirst() { p.addLine(to: pt) }
        }
    }

    private func gradientFill(points: [CGPoint], size: CGSize) -> some View {
        Path { p in
            guard let first = points.first else { return }
            p.move(to: CGPoint(x: first.x, y: size.height))
            p.addLine(to: first)
            for pt in points.dropFirst() { p.addLine(to: pt) }
            p.addLine(to: CGPoint(x: points.last!.x, y: size.height))
            p.closeSubpath()
        }
        .fill(LinearGradient(
            colors: [lineColor.opacity(0.34), lineColor.opacity(0.10), lineColor.opacity(0)],
            startPoint: .top, endPoint: .bottom
        ))
        .opacity(Double(trimValue))
    }

    private func formatPrice(_ price: Double) -> String {
        if price == 0      { return "—" }
        if price >= 1      { return String(format: "$%.2f", price) }
        if price >= 0.0001 { return String(format: "$%.5f", price) }
        return String(format: "$%.2e", price)
    }
}
