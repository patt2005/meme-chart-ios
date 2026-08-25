import SwiftUI

private let accent = Color(red: 0.776, green: 1.0, blue: 0.239)

struct FearGreedBadgeView: View {
    let index: FearGreedIndex

    var body: some View {
        HStack(spacing: 14) {
            gauge
            VStack(alignment: .leading, spacing: 3) {
                Text("FEAR & GREED")
                    .font(.system(size: 10, weight: .bold))
                    .kerning(0.6)
                    .foregroundStyle(Color(white: 1, opacity: 0.3))
                HStack(spacing: 5) {
                    Text(index.sentiment.emoji)
                        .font(.system(size: 15))
                    Text(index.sentiment.rawValue)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(sentimentColor)
                }
                Text("\(index.value) / 100")
                    .font(.system(size: 11).monospaced())
                    .foregroundStyle(Color(white: 1, opacity: 0.3))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(white: 1, opacity: 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(sentimentColor.opacity(0.22), lineWidth: 1)
        )
    }

    private var gauge: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color(white: 1, opacity: 0.10), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(135))
                .frame(width: 56, height: 56)

            Circle()
                .trim(from: 0, to: CGFloat(index.value) / 100.0 * 0.75)
                .stroke(
                    LinearGradient(colors: [sentimentColor.opacity(0.6), sentimentColor],
                                   startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
                .frame(width: 56, height: 56)
                .animation(.easeOut(duration: 0.9), value: index.value)
                .shadow(color: sentimentColor.opacity(0.5), radius: 6)

            Text("\(index.value)")
                .font(.system(size: 13, weight: .bold).monospaced())
                .foregroundStyle(.white)
        }
    }

    private var sentimentColor: Color {
        switch index.sentiment {
        case .extremeFear:  return Color(red: 0.95, green: 0.25, blue: 0.25)
        case .fear:         return Color(red: 0.95, green: 0.55, blue: 0.15)
        case .neutral:      return Color(red: 0.95, green: 0.85, blue: 0.20)
        case .greed:        return accent.opacity(0.85)
        case .extremeGreed: return accent
        }
    }
}
