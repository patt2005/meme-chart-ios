import Foundation

final class MarketService {
    static let shared = MarketService()
    private init() {}
    
    private struct SpotlightResponse: Decodable {
        let data: Payload
        
        struct Payload: Decodable {
            let gainerList: [Coin]?
            let loserList: [Coin]?
            let mostVisitedList: [Coin]?
            let recentlyAddedList: [Coin]?
            let trendingList: [Coin]?
            
            private enum CodingKeys: CodingKey {
                case gainerList, loserList, mostVisitedList, recentlyAddedList, trendingList
            }
            
            init(from decoder: Decoder) throws {
                let c = try decoder.container(keyedBy: CodingKeys.self)
                gainerList        = (try? c.decode([Coin?].self, forKey: .gainerList))?.compactMap { $0 }
                loserList         = (try? c.decode([Coin?].self, forKey: .loserList))?.compactMap { $0 }
                mostVisitedList   = (try? c.decode([Coin?].self, forKey: .mostVisitedList))?.compactMap { $0 }
                recentlyAddedList = (try? c.decode([Coin?].self, forKey: .recentlyAddedList))?.compactMap { $0 }
                trendingList      = (try? c.decode([Coin?].self, forKey: .trendingList))?.compactMap { $0 }
            }
        }
    }
    
    private struct DexSearchResponse: Decodable {
        let data: Payload
        struct Payload: Decodable {
            let tks: [Token]
        }
        struct Token: Decodable {
            let n: String
            let s: String
            let addr: String
            let pu: String?
            let pc24h: String?
            let v24h: String?
            let mc: String?
            let l: String?
            let cid: Int?
            let plt: String?

            private enum CodingKeys: String, CodingKey {
                case n, s, addr, pu, pc24h, v24h, mc, l, cid, plt
            }
        }
    }
    
    private struct FearGreedResponse: Decodable {
        let data: [FearGreedEntry]
        
        struct FearGreedEntry: Decodable {
            let value: String
            let valueClassification: String
            let timestamp: String
            
            private enum CodingKeys: String, CodingKey {
                case value
                case valueClassification = "value_classification"
                case timestamp
            }
        }
    }
    
    func fetchGainersAndLosers(timeframe: String) async throws -> (gainers: [Coin], losers: [Coin]) {
        let decoded = try await get(SpotlightResponse.self, from: spotlightURL(timeframe: timeframe))
        return (decoded.data.gainerList ?? [], decoded.data.loserList ?? [])
    }
    
    func fetchMostVisited(timeframe: String) async throws -> [Coin] {
        let t = timeframe == "1h" ? "24h" : timeframe
        let decoded = try await get(SpotlightResponse.self, from: spotlightURL(timeframe: t))
        return decoded.data.mostVisitedList ?? []
    }
    
    func fetchRecentlyAdded(timeframe: String) async throws -> [Coin] {
        let decoded = try await get(SpotlightResponse.self, from: spotlightURL(timeframe: timeframe))
        return decoded.data.recentlyAddedList ?? []
    }
    
    func fetchTrending(timeframe: String) async throws -> [Coin] {
        let decoded = try await get(SpotlightResponse.self, from: spotlightURL(timeframe: timeframe))
        return decoded.data.trendingList ?? []
    }
    
    func searchCoins(query: String) async throws -> [Coin] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://dapi.coinmarketcap.com/dex/v1/search?q=\(encoded)")
        else { return [] }

        let decoded = try await get(DexSearchResponse.self, from: url)
        var seenAddr = Set<String>()
        var seenId   = Set<Int>()
        return decoded.data.tks.compactMap { token -> Coin? in
            guard seenAddr.insert(token.addr.lowercased()).inserted else { return nil }
            let price     = token.pu.flatMap(Double.init)
            let change24h = token.pc24h.flatMap(Double.init)
            let volume    = token.v24h.flatMap(Double.init)
            let mktCap    = token.mc.flatMap(Double.init)
            let coinId: Int
            if let cid = token.cid, cid > 0 {
                coinId = cid
            } else {
                let hex = String(token.addr.suffix(8))
                coinId = -(Int(hex, radix: 16) ?? abs(token.addr.hashValue) % 1_000_000) % 1_000_000_000
            }
            guard seenId.insert(coinId).inserted else { return nil }
            let slug = token.s.lowercased().replacingOccurrences(of: " ", with: "-")
            return Coin(
                id: coinId,
                name: token.n,
                symbol: token.s.uppercased(),
                slug: slug,
                rank: nil,
                marketCap: mktCap,
                price: price,
                priceChange1h: nil,
                priceChange24h: change24h,
                priceChange7d: nil,
                volume24h: volume,
                logoURLOverride: token.l
            )
        }
    }
    
    func fetchFearGreedIndex() async throws -> FearGreedIndex {
        let url = URL(string: "https://api.alternative.me/fng/?limit=1")!
        let decoded = try await get(FearGreedResponse.self, from: url)
        guard let entry = decoded.data.first, let value = Int(entry.value) else {
            throw URLError(.cannotParseResponse)
        }
        return FearGreedIndex(value: value, classification: entry.valueClassification, timestamp: entry.timestamp)
    }
    
    private func spotlightURL(timeframe: String) -> URL {
        var comps = URLComponents(string: "https://api.coinmarketcap.com/data-api/v3/cryptocurrency/spotlight")!
        comps.queryItems = [
            .init(name: "rankRange", value: "0"),
            .init(name: "timeframe", value: timeframe),
            .init(name: "convert",   value: "USD"),
            .init(name: "limit",     value: "30")
        ]
        return comps.url!
    }
    
    private func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accepts")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(type, from: data)
    }
}
