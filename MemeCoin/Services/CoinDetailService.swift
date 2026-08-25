import Foundation

final class CoinDetailService {
    static let shared = CoinDetailService()
    private init() {}

    private func session() -> URLSession { .shared }

    private struct DetailResponse: Decodable {
        let data: CoinDetail
    }

    private struct ChartResponse: Decodable {
        let data: ChartData

        struct ChartData: Decodable {
            let points: [String: PointValue]

            struct PointValue: Decodable {
                let price: Double

                private enum CodingKeys: String, CodingKey { case v }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    var arr = try container.nestedUnkeyedContainer(forKey: .v)
                    price = (try? arr.decode(Double.self)) ?? 0
                }
            }
        }
    }

    private struct FearGreedChartResponse: Decodable {
        let data: HistoricalData

        struct HistoricalData: Decodable {
            let historicalValues: HistoricalValues

            struct HistoricalValues: Decodable {
                let now: NowValue

                struct NowValue: Decodable {
                    let score: Int
                }
            }
        }
    }

    func fetchCoinDetail(id: Int) async throws -> CoinDetail? {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/?id=\(id)") else { return nil }
        let response = try await get(DetailResponse.self, from: url)
        return response.data
    }

    func fetchPriceHistory(id: Int, range: ChartTimeRange) async throws -> [Double] {
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=\(id)&range=\(range.apiParam)") else { return [] }

        let response = try await get(ChartResponse.self, from: url)

        var pricePoints: [Int: Double] = [:]
        for (timestamp, point) in response.data.points {
            if let ts = Int(timestamp) {
                pricePoints[ts] = point.price
            }
        }

        return pricePoints.keys.sorted().compactMap { pricePoints[$0] }
    }

    func fetchFearGreedScore() async throws -> Double? {
        let end = Int(Date().timeIntervalSince1970)
        let start = end - 2_672_824
        guard let url = URL(string: "https://api.coinmarketcap.com/data-api/v3/fear-greed/chart?start=\(start)&end=\(end)") else { return nil }

        let response = try await get(FearGreedChartResponse.self, from: url)
        return Double(response.data.historicalValues.now.score)
    }

    private func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accepts")
        let (data, _) = try await session().data(for: request)
        print("Got this data: \(String(decoding: data, as: UTF8.self))")
        return try JSONDecoder().decode(type, from: data)
    }
}
