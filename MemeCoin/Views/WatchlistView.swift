import SwiftUI

private let accent = Color(red: 0.776, green: 1.0, blue: 0.239)
private let bg     = Color(red: 0.031, green: 0.027, blue: 0.047)

struct WatchlistView: View {
    @ObservedObject private var watchlist = WatchlistStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            bg.ignoresSafeArea()

            RadialGradient(
                colors: [Color(red: 0.545, green: 0.361, blue: 1.0).opacity(0.15), .clear],
                center: .init(x: 0.82, y: 0.05),
                startRadius: 0, endRadius: 620
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                if watchlist.watchedCoins.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 9) {
                            ForEach(watchlist.watchedCoins) { coin in
                                NavigationLink(destination: CoinDetailView(coin: coin)) {
                                    WatchlistRowView(coin: coin)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var headerBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color(white: 1, opacity: 0.07))
                        .overlay(Circle().stroke(Color(white: 1, opacity: 0.10), lineWidth: 1))
                        .frame(width: 38, height: 38)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text("Watchlist")
                    .font(.custom("Georgia-Bold", size: 22))
                    .foregroundStyle(.white)
                    .kerning(-0.4)
                if !watchlist.watchedCoins.isEmpty {
                    Text("\(watchlist.watchedCoins.count) coin\(watchlist.watchedCoins.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(white: 1, opacity: 0.38))
                }
            }

            Spacer()

            Color.clear.frame(width: 38, height: 38)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 22)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(white: 1, opacity: 0.04))
                    .frame(width: 80, height: 80)
                Image(systemName: "star.slash")
                    .font(.system(size: 32, weight: .thin))
                    .foregroundStyle(Color(white: 1, opacity: 0.22))
            }
            VStack(spacing: 7) {
                Text("No coins watched")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(white: 1, opacity: 0.55))
                Text("Tap Watch on any coin detail page\nto add it here.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(white: 1, opacity: 0.3))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

struct WatchlistRowView: View {
    let coin: Coin

    private var priceChange: Double? { coin.priceChange24h }
    private var isUp: Bool { (priceChange ?? 0) >= 0 }
    private var changeColor: Color {
        isUp ? Color(red: 0.776, green: 1.0, blue: 0.239) : Color(red: 1, green: 0.329, blue: 0.439)
    }

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: coin.logoURL.flatMap(URL.init)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.545, green: 0.361, blue: 1.0).opacity(0.55),
                                 Color(red: 0.776, green: 1.0, blue: 0.239).opacity(0.45)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    Text(String(coin.symbol.prefix(1)))
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.65))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 3) {
                Text(coin.symbol)
                    .font(.system(size: 15.5, weight: .bold))
                    .foregroundStyle(.white)
                    .kerning(-0.2)
                Text(coin.name)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color(white: 1, opacity: 0.38))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatPrice(coin.price ?? 0))
                    .font(.system(size: 15.5, weight: .semibold).monospaced())
                    .foregroundStyle(.white)
                    .kerning(-0.3)

                if let change = priceChange {
                    HStack(spacing: 3) {
                        Image(systemName: isUp ? "arrow.up" : "arrow.down")
                            .font(.system(size: 9, weight: .bold))
                        Text(String(format: "%.2f%%", abs(change)))
                            .font(.system(size: 12, weight: .bold).monospaced())
                    }
                    .foregroundStyle(changeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(changeColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 7))
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(white: 1, opacity: 0.2))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color(white: 1, opacity: 0.045))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(white: 1, opacity: 0.07), lineWidth: 1))
    }

    private func formatPrice(_ price: Double) -> String {
        if price == 0      { return "—" }
        if price >= 1      { return String(format: "$%.2f", price) }
        if price >= 0.0001 { return String(format: "$%.5f", price) }
        return String(format: "$%.2e", price)
    }
}
