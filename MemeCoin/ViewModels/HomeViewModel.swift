import Foundation
import Combine

enum MarketCategory: String, CaseIterable, Identifiable {
    case gainers     = "Gainers"
    case losers      = "Losers"
    case trending    = "Trending"
    case mostVisited = "Most Visited"
    case newListings = "New Listings"

    var id: String { rawValue }
}

enum TimeRange: String, CaseIterable, Identifiable {
    case oneHour      = "1h"
    case twentyFourH  = "24h"
    case sevenDays    = "7d"

    var id: String { rawValue }
    var label: String { rawValue }
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var fearGreedIndex: FearGreedIndex?
    @Published var selectedCategory: MarketCategory = .gainers
    @Published var selectedTimeRange: TimeRange = .twentyFourH
    @Published var searchQuery: String = ""
    @Published var searchResults: [Coin] = []
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?

    private let service = MarketService.shared
    private var searchTask: Task<Void, Never>?

    func loadData() async {
        async let coins = fetchCoins()
        async let fg = fetchFearGreed()
        self.coins = await coins
        self.fearGreedIndex = await fg
    }

    func onCategoryChanged() async {
        isLoading = true
        await loadData()
        isLoading = false
    }

    func onTimeRangeChanged() async {
        isLoading = true
        await loadData()
        isLoading = false
    }

    func onSearchQueryChanged(_ query: String) {
        searchTask?.cancel()
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        isSearching = true
        searchTask = Task {
            guard !Task.isCancelled else { isSearching = false; return }
            do {
                let results = try await service.searchCoins(query: query)
                searchResults = results
            } catch {
                searchResults = []
            }
            isSearching = false
        }
    }

    private func fetchCoins() async -> [Coin] {
        let t = selectedTimeRange.rawValue
        do {
            switch selectedCategory {
            case .gainers:
                return try await service.fetchGainersAndLosers(timeframe: t).gainers
            case .losers:
                return try await service.fetchGainersAndLosers(timeframe: t).losers
            case .trending:
                return try await service.fetchTrending(timeframe: t)
            case .mostVisited:
                return try await service.fetchMostVisited(timeframe: t)
            case .newListings:
                return try await service.fetchRecentlyAdded(timeframe: t)
            }
        } catch {
            errorMessage = "Failed to load coins."
            return []
        }
    }

    private func fetchFearGreed() async -> FearGreedIndex? {
        try? await service.fetchFearGreedIndex()
    }

}
