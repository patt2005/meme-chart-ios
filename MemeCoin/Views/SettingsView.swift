import SwiftUI

private let accent = Color(red: 0.776, green: 1.0, blue: 0.239)
private let bg     = Color(red: 0.031, green: 0.027, blue: 0.047)

struct SettingsView: View {
    @ObservedObject private var watchlist = WatchlistStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var fearGreed: FearGreedIndex?

    var body: some View {
        ZStack(alignment: .top) {
            bg.ignoresSafeArea()

            RadialGradient(
                colors: [Color(red: 0.545, green: 0.361, blue: 1.0).opacity(0.16), .clear],
                center: .init(x: 0.82, y: -0.1),
                startRadius: 0, endRadius: 560
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        watchlistHeader
                        watchlistSection
                        sectionHeader("MARKET SENTIMENT")
                        fearGreedSection
                        sectionHeader("APP")
                        appSection
                        Spacer().frame(height: 48)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { fearGreed = try? await MarketService.shared.fetchFearGreedIndex() }
    }

    private var headerBar: some View {
        HStack(alignment: .center) {
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

            Text("Settings")
                .font(.custom("Georgia-Bold", size: 22))
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .kerning(-0.4)

            Spacer()
            Color.clear.frame(width: 38, height: 38)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 22)
    }

    private var watchlistHeader: some View {
        HStack {
            Text("WATCHLIST")
                .font(.system(size: 11.5, weight: .bold))
                .kerning(0.5)
                .foregroundStyle(Color(white: 1, opacity: 0.34))
            Spacer()
            if !watchlist.watchedCoins.isEmpty {
                NavigationLink(destination: WatchlistView()) {
                    Text("See All")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .padding(.bottom, 11)
    }

    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 11.5, weight: .bold))
                .kerning(0.5)
                .foregroundStyle(Color(white: 1, opacity: 0.34))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .padding(.bottom, 11)
    }

    private var watchlistSection: some View {
        Group {
            if watchlist.watchedCoins.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(white: 1, opacity: 0.22))
                    Text("No coins watched yet")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(white: 1, opacity: 0.32))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(Color(white: 1, opacity: 0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(white: 1, opacity: 0.07), lineWidth: 1))
                .padding(.horizontal, 18)
            } else {
                VStack(spacing: 0) {
                    ForEach(watchlist.watchedCoins.prefix(3)) { coin in
                        watchedRow(coin: coin)
                    }
                }
                .background(Color(white: 1, opacity: 0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(white: 1, opacity: 0.07), lineWidth: 1))
                .padding(.horizontal, 18)
            }
        }
    }

    private func watchedRow(coin: Coin) -> some View {
        NavigationLink(destination: CoinDetailView(coin: coin)) {
            HStack(spacing: 13) {
                AsyncImage(url: coin.logoURL.flatMap(URL.init)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ZStack {
                        LinearGradient(
                            colors: [Color(red: 0.545, green: 0.361, blue: 1.0).opacity(0.5), accent.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        Text(String(coin.symbol.prefix(1)))
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(Color.black.opacity(0.6))
                    }
                }
                .frame(width: 38, height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.symbol)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text(coin.name)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(white: 1, opacity: 0.36))
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        watchlist.toggle(id: coin.id)
                    }
                } label: {
                    Image(systemName: "star.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(accent)
                        .shadow(color: accent.opacity(0.5), radius: 6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color(white: 1, opacity: 0.06))
                    .frame(height: 0.5)
                    .padding(.leading, 67)
            }
        }
        .buttonStyle(.plain)
    }

    private var fearGreedSection: some View {
        Group {
            if let fg = fearGreed {
                FearGreedBarCard(index: fg)
                    .padding(.horizontal, 18)
            } else {
                HStack {
                    ProgressView().tint(accent)
                    Text("Loading…")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(white: 1, opacity: 0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(white: 1, opacity: 0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(white: 1, opacity: 0.07), lineWidth: 1))
                .padding(.horizontal, 18)
            }
        }
    }

    private var appSection: some View {
        VStack(spacing: 0) {
            infoRow(label: "Version", value: "1.0.0")
            Divider().background(Color(white: 1, opacity: 0.06)).padding(.leading, 16)
            linkRow(label: "Privacy Policy",  icon: "lock.shield",       url: "https://www.termsfeed.com/live/2d09dd99-77e0-4e29-8aed-96da3ba8561b")
            Divider().background(Color(white: 1, opacity: 0.06)).padding(.leading, 16)
            linkRow(label: "Terms of Service", icon: "doc.text",         url: "https://www.termsfeed.com/live/9b77d74d-66c3-45d3-871e-b32d0548b682")
            Divider().background(Color(white: 1, opacity: 0.06)).padding(.leading, 16)
            linkRow(label: "Contact Us",       icon: "envelope",         url: "mailto:michaelwhitaker872@gmail.com", isLast: true)
        }
        .background(Color(white: 1, opacity: 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(white: 1, opacity: 0.07), lineWidth: 1))
        .padding(.horizontal, 18)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(Color(white: 1, opacity: 0.38))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }

    private func linkRow(label: String, icon: String, url: String, isLast: Bool = false) -> some View {
        Button {
            if let u = URL(string: url) { UIApplication.shared.open(u) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(accent)
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(white: 1, opacity: 0.25))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
        }
        .buttonStyle(.plain)
    }
}

private struct FearGreedBarCard: View {
    let index: FearGreedIndex

    private var progress: Double { Double(index.value) / 100.0 }

    private var barColor: Color {
        switch index.sentiment {
        case .extremeFear:  return Color(red: 0.95, green: 0.25, blue: 0.25)
        case .fear:         return Color(red: 0.95, green: 0.55, blue: 0.15)
        case .neutral:      return Color(red: 0.95, green: 0.85, blue: 0.20)
        case .greed:        return Color(red: 0.776, green: 1.0, blue: 0.239).opacity(0.85)
        case .extremeGreed: return Color(red: 0.776, green: 1.0, blue: 0.239)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("FEAR & GREED INDEX")
                        .font(.system(size: 11, weight: .bold))
                        .kerning(0.5)
                        .foregroundStyle(Color(white: 1, opacity: 0.34))
                    HStack(spacing: 6) {
                        Text(index.sentiment.emoji)
                            .font(.system(size: 22))
                        Text(index.sentiment.rawValue)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(barColor)
                            .kerning(-0.3)
                    }
                }
                Spacer()
                Text("\(index.value)")
                    .font(.system(size: 44, weight: .bold).monospaced())
                    .foregroundStyle(.white)
                    .kerning(-2)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(white: 1, opacity: 0.08))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.95, green: 0.25, blue: 0.25),
                                    Color(red: 0.95, green: 0.55, blue: 0.15),
                                    Color(red: 0.95, green: 0.85, blue: 0.20),
                                    Color(red: 0.776, green: 1.0, blue: 0.239)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 10)
                        .shadow(color: barColor.opacity(0.55), radius: 8)
                        .animation(.easeOut(duration: 0.9), value: progress)

                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .shadow(color: barColor.opacity(0.7), radius: 6)
                        .offset(x: max(0, geo.size.width * progress - 8))
                        .animation(.easeOut(duration: 0.9), value: progress)
                }
            }
            .frame(height: 16)

            HStack {
                Text("Fear")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(red: 0.95, green: 0.25, blue: 0.25).opacity(0.8))
                Spacer()
                Text("Neutral")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(white: 1, opacity: 0.28))
                Spacer()
                Text("Greed")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(red: 0.776, green: 1.0, blue: 0.239).opacity(0.8))
            }
        }
        .padding(18)
        .background(Color(white: 1, opacity: 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(barColor.opacity(0.22), lineWidth: 1)
        )
    }
}
