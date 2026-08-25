import Foundation
import Combine

@MainActor
final class CoinDetailViewModel: ObservableObject {
    @Published var detail: CoinDetail?
    @Published var priceHistory: [Double] = []
    @Published var selectedRange: ChartTimeRange = .oneDay
    @Published var selectedPrice: Double = 0
    @Published var isLoadingDetail: Bool = false
    @Published var isLoadingChart: Bool = false
    @Published var errorMessage: String?

    private let service = CoinDetailService.shared
    let coin: Coin
    var coinId: Int     { coin.id }
    var coinName: String   { coin.name }
    var coinSymbol: String { coin.symbol }

    init(coin: Coin) {
        self.coin = coin
    }

    func loadAll() async {
        await loadDetail()
        await loadChart()
    }

    func loadDetail() async {
        isLoadingDetail = true
        do {
            detail = try await service.fetchCoinDetail(id: coinId)
        } catch {
            errorMessage = "Could not load coin details."
        }
        isLoadingDetail = false
    }

    func loadChart() async {
        isLoadingChart = true
        do {
            let prices = try await service.fetchPriceHistory(id: coinId, range: selectedRange)
            priceHistory  = prices
            selectedPrice = prices.last ?? 0
        } catch {
            print("got this error: \(error.localizedDescription)")
            priceHistory = []
        }
        isLoadingChart = false
    }

    func changeRange(_ range: ChartTimeRange) async {
        selectedRange = range
        await loadChart()
    }

    var priceChangeForRange: Double? {
        switch selectedRange {
        case .oneHour:   return detail?.priceChange1h
        case .oneDay:    return detail?.priceChange24h
        case .sevenDays: return detail?.priceChange7d
        case .oneMonth:  return detail?.priceChange30d
        case .oneYear:   return detail?.priceChange24h
        }
    }
}
