import SwiftUI

private let accent = Color(red: 0.776, green: 1.0, blue: 0.239)

struct CoinRowView: View {
    let coin: Coin
    let rank: Int
    let isTop: Bool

    var body: some View {
        NavigationLink(destination: CoinDetailView(coin: coin)) {
            HStack(spacing: 13) {
                Text("\(rank)")
                    .font(.system(size: 12.5, weight: .bold).monospaced())
                    .foregroundStyle(rank <= 3 ? accent : Color(white: 1, opacity: 0.3))
                    .frame(width: 18, alignment: .center)

                coinLogo
                    .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.symbol)
                        .font(.system(size: 18, weight: .heavy))
                        .kerning(-0.3)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(coin.name)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(white: 1, opacity: 0.4))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text(formatPrice(coin.price ?? 0))
                        .font(.system(size: 15, weight: .medium).monospaced())
                        .foregroundStyle(.white)
                        .kerning(-0.3)
                    changeChip(value: coin.priceChange24h)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                isTop
                    ? LinearGradient(
                        colors: [accent.opacity(0.14), Color(white: 1, opacity: 0.04)],
                        startPoint: .init(x: 0.1, y: 0),
                        endPoint: .trailing
                      )
                    : LinearGradient(
                        colors: [Color(white: 1, opacity: 0.04), Color(white: 1, opacity: 0.04)],
                        startPoint: .leading,
                        endPoint: .trailing
                      ),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isTop ? accent.opacity(0.34) : Color(white: 1, opacity: 0.07),
                        lineWidth: 1
                    )
            )
            .shadow(color: isTop ? accent.opacity(0.12) : .clear, radius: 16, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var coinLogo: some View {
        Group {
            if let url = coin.logoURL.flatMap(URL.init) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    placeholderAvatar
                }
            } else {
                placeholderAvatar
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private var placeholderAvatar: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1, green: 0.42, blue: 0.42), Color(red: 1, green: 0.82, blue: 0.4)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Text(String(coin.symbol.prefix(1)))
                .font(.system(size: 19, weight: .heavy))
                .foregroundStyle(Color.black.opacity(0.72))
        }
    }

    private func changeChip(value: Double?) -> some View {
        guard let v = value else {
            return AnyView(Text("—")
                .font(.system(size: 12.5, weight: .bold).monospaced())
                .foregroundStyle(Color(white: 1, opacity: 0.25)))
        }
        let up  = v >= 0
        let fg  = up ? accent : Color(red: 1, green: 0.5, blue: 0.58)
        let bg  = up ? accent.opacity(0.16) : Color(red: 1, green: 0.33, blue: 0.44).opacity(0.16)
        return AnyView(
            Text(String(format: "%@%.1f%%", up ? "+" : "", v))
                .font(.system(size: 12.5, weight: .bold).monospaced())
                .foregroundStyle(fg)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(bg, in: RoundedRectangle(cornerRadius: 8))
        )
    }

    private func formatPrice(_ price: Double) -> String {
        if price == 0      { return "—" }
        if price >= 1      { return String(format: "$%.2f", price) }
        if price >= 0.0001 { return String(format: "$%.5f", price) }
        return String(format: "$%.2e", price)
    }
}
