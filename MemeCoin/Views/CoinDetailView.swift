import SwiftUI

private let accent = Color(red: 0.776, green: 1.0, blue: 0.239)
private let bg     = Color(red: 0.031, green: 0.027, blue: 0.047)

struct CoinDetailView: View {
    @StateObject private var vm: CoinDetailViewModel
    @ObservedObject private var watchlist = WatchlistStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    init(coin: Coin) {
        _vm = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }

    private var lineColor: Color {
        let chartChange: Double? = {
            guard vm.priceHistory.count >= 2,
                  let first = vm.priceHistory.first,
                  let last  = vm.priceHistory.last,
                  first != 0 else { return nil }
            return last - first
        }()
        let change = chartChange ?? vm.priceChangeForRange ?? 0
        return change >= 0 ? accent : Color(red: 1, green: 0.329, blue: 0.439)
    }

    var body: some View {
        ZStack(alignment: .top) {
            bg.ignoresSafeArea()

            RadialGradient(
                colors: [lineColor.opacity(0.20), .clear],
                center: .init(x: 0.5, y: -0.05),
                startRadius: 0, endRadius: 440
            )
            .frame(height: 460)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 8)
                    navBar
                    coinHeader
                    priceBlock
                    chartSection
                    rangeSelector
                    statsGrid
                    if let desc = vm.detail?.description, !desc.isEmpty {
                        aboutCard(desc)
                    }
                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .task { await vm.loadAll() }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color(white: 1, opacity: 0.08))
                        .overlay(Circle().stroke(Color(white: 1, opacity: 0.11), lineWidth: 1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 9) {
                let isWatched = watchlist.isWatched(vm.coinId)
                Button {
                    watchlist.toggle(coin: vm.coin)
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: isWatched ? "star.fill" : "star")
                            .font(.system(size: 13))
                            .foregroundStyle(isWatched ? accent : Color(white: 1, opacity: 0.7))
                        Text(isWatched ? "Watching" : "Watch")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 40)
                    .background(isWatched ? accent.opacity(0.15) : Color(white: 1, opacity: 0.08))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(isWatched ? accent.opacity(0.4) : Color(white: 1, opacity: 0.11), lineWidth: 1))
                    .shadow(color: isWatched ? accent.opacity(0.25) : .clear, radius: 8, y: 3)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: isWatched)

                Button { showShareSheet = true } label: {
                    ZStack {
                        Circle()
                            .fill(Color(white: 1, opacity: 0.08))
                            .overlay(Circle().stroke(Color(white: 1, opacity: 0.11), lineWidth: 1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [shareText])
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 22)
    }

    private var coinHeader: some View {
        HStack(spacing: 12) {
            AsyncImage(url: vm.coin.logoURL.flatMap(URL.init)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ZStack {
                    LinearGradient(colors: [Color(red: 1, green: 0.42, blue: 0.42), Color(red: 1, green: 0.82, blue: 0.4)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text(String(vm.coinSymbol.prefix(1)))
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.72))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(vm.coinSymbol)
                    .font(.system(size: 22, weight: .heavy))
                    .kerning(-0.4)
                    .foregroundStyle(.white)
                Text(vm.coinName)
                    .font(.system(size: 13.5))
                    .foregroundStyle(Color(white: 1, opacity: 0.4))
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 14)
    }

    private var priceBlock: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Text(formatPrice(vm.selectedPrice))
                .font(.system(size: 42, weight: .bold).monospaced())
                .foregroundStyle(.white)
                .kerning(-1.5)
                .contentTransition(.numericText())

            if let change = vm.priceChangeForRange {
                let up = change >= 0
                let fg = up ? accent : Color(red: 1, green: 0.5, blue: 0.58)
                let bg2 = up ? accent.opacity(0.16) : Color(red: 1, green: 0.33, blue: 0.44).opacity(0.16)
                Text(String(format: "%@%.1f%%", up ? "+" : "", change))
                    .font(.system(size: 14, weight: .bold).monospaced())
                    .foregroundStyle(fg)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(bg2, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.bottom, 6)
    }

    private var chartSection: some View {
        ZStack {
            if vm.isLoadingChart {
                ProgressView().tint(accent)
                    .frame(height: 262)
            } else {
                PriceChartView(
                    priceList: vm.priceHistory,
                    lineColor: lineColor,
                    selectedPrice: $vm.selectedPrice
                )
                .frame(height: 262)
            }
        }
        .padding(.bottom, 6)
    }

    private var rangeSelector: some View {
        HStack(spacing: 7) {
            ForEach(ChartTimeRange.allCases) { range in
                let sel = vm.selectedRange == range
                Button {
                    Task { await vm.changeRange(range) }
                } label: {
                    Text(range.label)
                        .font(.system(size: 13, weight: .bold).monospaced())
                        .foregroundStyle(sel ? .white : Color(white: 1, opacity: 0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            sel ? Color(white: 1, opacity: 0.10) : Color(white: 1, opacity: 0.03),
                            in: RoundedRectangle(cornerRadius: 13)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(
                                    sel ? Color(white: 1, opacity: 0.14) : Color(white: 1, opacity: 0.05),
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.14), value: sel)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 26)
    }

    private var statsGrid: some View {
        VStack(spacing: 0) {
            sectionLabel("MARKET STATS")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                statCard(label: "MARKET CAP",   value: formatLarge(vm.detail?.marketCap), color: .white)
                statCard(label: "VOLUME 24H",   value: formatLarge(vm.detail?.volume24h), color: .white)
                statCard(label: "CIRCULATING",  value: formatLarge(vm.detail?.circulatingSupply), color: .white)
                statCard(label: "TOTAL SUPPLY", value: formatLarge(vm.detail?.totalSupply), color: .white)
                statCard(label: "ALL-TIME HIGH", value: formatPrice(vm.detail?.allTimeHigh ?? 0), color: Color(white: 1, opacity: 0.72))
                statCard(label: "ALL-TIME LOW",  value: formatPrice(vm.detail?.allTimeLow ?? 0), color: Color(white: 1, opacity: 0.72))
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 4)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 11.5, weight: .bold))
                .kerning(0.5)
                .foregroundStyle(Color(white: 1, opacity: 0.34))
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 12)
        .padding(.top, 8)
    }

    private func statCard(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 11.5, weight: .bold))
                .kerning(0.4)
                .foregroundStyle(Color(white: 1, opacity: 0.34))
            Text(value)
                .font(.system(size: 16, weight: .medium).monospaced())
                .foregroundStyle(color)
                .kerning(-0.3)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color(white: 1, opacity: 0.045))
        .clipShape(RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(Color(white: 1, opacity: 0.07), lineWidth: 1))
    }

    private func aboutCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("ABOUT")
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Color(white: 1, opacity: 0.62))
                .lineSpacing(6)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.545, green: 0.361, blue: 1.0).opacity(0.14),
                                 Color(white: 1, opacity: 0.03)],
                        startPoint: .init(x: 0.15, y: 0),
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 19))
                .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color(white: 1, opacity: 0.08), lineWidth: 1))
                .padding(.horizontal, 18)
        }
    }

    private func formatPrice(_ price: Double) -> String {
        if price == 0      { return "—" }
        if price >= 1      { return String(format: "$%.2f", price) }
        if price >= 0.0001 { return String(format: "$%.5f", price) }
        return String(format: "$%.2e", price)
    }

    private func formatLarge(_ value: Double?) -> String {
        guard let v = value, v > 0 else { return "—" }
        switch v {
        case 1_000_000_000_000...: return String(format: "$%.2fT", v / 1_000_000_000_000)
        case 1_000_000_000...:     return String(format: "$%.2fB", v / 1_000_000_000)
        case 1_000_000...:         return String(format: "$%.2fM", v / 1_000_000)
        default:                   return String(format: "$%.2f", v)
        }
    }

    private var shareText: String {
        var lines: [String] = []
        lines.append("\(vm.coinSymbol) — \(vm.coinName)")
        lines.append("Price: \(formatPrice(vm.selectedPrice))")
        if let change = vm.priceChangeForRange {
            let sign = change >= 0 ? "+" : ""
            lines.append("Change (\(vm.selectedRange.label)): \(sign)\(String(format: "%.2f", change))%")
        }
        if let d = vm.detail {
            lines.append("Market Cap: \(formatLarge(d.marketCap))")
            lines.append("Volume 24h: \(formatLarge(d.volume24h))")
        }
        lines.append("\nTracked via Meme Chart")
        return lines.joined(separator: "\n")
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
