import SwiftUI

private let accent = Color(red: 0.776, green: 1.0, blue: 0.239)
private let bg     = Color(red: 0.031, green: 0.027, blue: 0.047)
private let card   = Color(white: 1, opacity: 0.04)
private let cardBorder = Color(white: 1, opacity: 0.07)

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                bg.ignoresSafeArea()

                RadialGradient(
                    colors: [Color(red: 0.545, green: 0.361, blue: 1.0).opacity(0.18), .clear],
                    center: .init(x: 0.05, y: 0.0),
                    startRadius: 0, endRadius: 700
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [Color(red: 0.776, green: 1.0, blue: 0.239).opacity(0.045), .clear],
                    center: .init(x: 1.1, y: 1.0),
                    startRadius: 0, endRadius: 500
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBar
                    searchBar
                    if vm.searchQuery.isEmpty {
                        filterStrip
                        timeStrip
                        Divider().background(Color(white: 1, opacity: 0.07))
                        coinList
                    } else {
                        searchResultsList
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .navigationBarHidden(true)
            .task {
                vm.isLoading = true
                await vm.loadData()
                vm.isLoading = false
            }
            .refreshable {
                await vm.loadData()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var headerBar: some View {
        HStack(alignment: .center) {
            HStack(spacing: 9) {
                Circle()
                    .fill(accent)
                    .frame(width: 11, height: 11)
                    .shadow(color: accent.opacity(0.9), radius: 7)
                Text("Meme Chart")
                    .font(.custom("Georgia-Bold", size: 26))
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                    .kerning(-0.5)
            }
            Spacer()
            NavigationLink(destination: SettingsView()) {
                ZStack {
                    Circle()
                        .fill(Color(white: 1, opacity: 0.07))
                        .overlay(Circle().stroke(Color(white: 1, opacity: 0.1), lineWidth: 1))
                        .frame(width: 38, height: 38)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(white: 1, opacity: 0.6))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    private var searchBar: some View {
        HStack(spacing: 11) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(white: 1, opacity: 0.45))
            TextField("", text: $vm.searchQuery, prompt:
                Text("Search coins, tickers, contracts")
                    .foregroundColor(Color(white: 1, opacity: 0.38))
            )
            .foregroundStyle(.white)
            .tint(accent)
            .autocorrectionDisabled()
            .onChange(of: vm.searchQuery) { new in vm.onSearchQueryChanged(new) }
            if !vm.searchQuery.isEmpty {
                Button { vm.searchQuery = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(white: 1, opacity: 0.35))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color(white: 1, opacity: 0.055))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(white: 1, opacity: 0.08), lineWidth: 1))
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MarketCategory.allCases) { cat in
                    categoryChip(cat)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
    }

    private func categoryChip(_ cat: MarketCategory) -> some View {
        let sel = vm.selectedCategory == cat
        return Button {
            vm.selectedCategory = cat
            Task { await vm.onCategoryChanged() }
        } label: {
            Text(cat.rawValue)
                .font(.system(size: 14.5, weight: .bold))
                .kerning(-0.1)
                .foregroundStyle(sel ? Color(red: 0.027, green: 0.027, blue: 0.039) : Color(white: 1, opacity: 0.62))
                .padding(.horizontal, 15)
                .padding(.vertical, 9)
                .background(
                    sel ? accent : Color(white: 1, opacity: 0.055),
                    in: RoundedRectangle(cornerRadius: 13)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(sel ? accent : Color(white: 1, opacity: 0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: sel)
    }

    private var timeStrip: some View {
        HStack(spacing: 6) {
            Text("WINDOW")
                .font(.system(size: 11.5, weight: .bold))
                .kerning(0.5)
                .foregroundStyle(Color(white: 1, opacity: 0.3))
                .padding(.trailing, 4)
            ForEach(TimeRange.allCases) { range in
                timeChip(range)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }

    private func timeChip(_ range: TimeRange) -> some View {
        let sel = vm.selectedTimeRange == range
        return Button {
            vm.selectedTimeRange = range
            Task { await vm.onTimeRangeChanged() }
        } label: {
            Text(range.label)
                .font(.system(size: 12, weight: .bold).monospaced())
                .foregroundStyle(sel ? .white : Color(white: 1, opacity: 0.34))
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(sel ? Color(white: 1, opacity: 0.10) : .clear,
                            in: RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.12), value: sel)
    }

    private var coinList: some View {
        Group {
            if vm.isLoading {
                VStack(spacing: 14) {
                    ProgressView().tint(accent).scaleEffect(1.1)
                    Text("Loading…")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(white: 1, opacity: 0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.coins.isEmpty {
                EmptyStateView(systemImage: "chart.bar.xaxis", title: "No coins found", subtitle: "Try a different category or time range")
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 9) {
                        ForEach(Array(vm.coins.enumerated()), id: \.element.id) { idx, coin in
                            CoinRowView(coin: coin, rank: idx + 1, isTop: idx == 0)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private var searchResultsList: some View {
        Group {
            if vm.isSearching {
                VStack(spacing: 14) {
                    ProgressView().tint(accent).scaleEffect(1.1)
                    Text("Searching…")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(white: 1, opacity: 0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.searchResults.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "No results for \"\(vm.searchQuery)\"",
                    subtitle: "Try a different keyword"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 9) {
                        ForEach(Array(vm.searchResults.enumerated()), id: \.element.id) { idx, coin in
                            CoinRowView(coin: coin, rank: idx + 1, isTop: false)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}
