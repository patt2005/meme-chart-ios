import Foundation
import Combine

final class WatchlistStore: ObservableObject {
    static let shared = WatchlistStore()

    @Published private(set) var watchedCoins: [Coin] = []

    private let key = "watchlist_coins_v2"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let coins = try? JSONDecoder().decode([Coin].self, from: data) {
            watchedCoins = coins
        }
    }

    var watchedIDs: Set<Int> { Set(watchedCoins.map(\.id)) }

    func toggle(coin: Coin) {
        if isWatched(coin.id) {
            watchedCoins.removeAll { $0.id == coin.id }
        } else {
            watchedCoins.append(coin)
        }
        persist()
    }

    func toggle(id: Int) {
        watchedCoins.removeAll { $0.id == id }
        persist()
    }

    func isWatched(_ id: Int) -> Bool {
        watchedCoins.contains { $0.id == id }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(watchedCoins) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
