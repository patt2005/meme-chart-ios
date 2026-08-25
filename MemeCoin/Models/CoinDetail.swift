import Foundation

struct CoinDetail: Decodable, Sendable {
    let id: Int
    let name: String
    let symbol: String
    let slug: String
    let description: String?
    let rank: Int?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let marketCap: Double?
    let price: Double?
    let volume24h: Double?
    let priceChange1h: Double?
    let priceChange24h: Double?
    let priceChange7d: Double?
    let priceChange30d: Double?
    let allTimeHigh: Double?
    let allTimeLow: Double?

    var logoURL: String {
        "https://s2.coinmarketcap.com/static/img/coins/128x128/\(id).png"
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug, description
        case volume, statistics
    }

    private enum StatKeys: String, CodingKey {
        case price
        case marketCap
        case volume24h                    = "volume24h"
        case circulatingSupply
        case totalSupply
        case maxSupply
        case rank
        case priceChange1h                = "priceChangePercentage1h"
        case priceChange24h               = "priceChangePercentage24h"
        case priceChange7d                = "priceChangePercentage7d"
        case priceChange30d               = "priceChangePercentage30d"
        case highAllTime
        case lowAllTime
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(Int.self,    forKey: .id)
        name        = try c.decode(String.self, forKey: .name)
        symbol      = try c.decode(String.self, forKey: .symbol)
        slug        = try c.decode(String.self, forKey: .slug)
        description = try? c.decodeIfPresent(String.self, forKey: .description)

        volume24h = try? c.decodeIfPresent(Double.self, forKey: .volume)

        if let s = try? c.nestedContainer(keyedBy: StatKeys.self, forKey: .statistics) {
            price             = try? s.decodeIfPresent(Double.self, forKey: .price)
            marketCap         = try? s.decodeIfPresent(Double.self, forKey: .marketCap)
            circulatingSupply = try? s.decodeIfPresent(Double.self, forKey: .circulatingSupply)
            totalSupply       = try? s.decodeIfPresent(Double.self, forKey: .totalSupply)
            maxSupply         = try? s.decodeIfPresent(Double.self, forKey: .maxSupply)
            rank              = try? s.decodeIfPresent(Int.self,    forKey: .rank)
            priceChange1h     = try? s.decodeIfPresent(Double.self, forKey: .priceChange1h)
            priceChange24h    = try? s.decodeIfPresent(Double.self, forKey: .priceChange24h)
            priceChange7d     = try? s.decodeIfPresent(Double.self, forKey: .priceChange7d)
            priceChange30d    = try? s.decodeIfPresent(Double.self, forKey: .priceChange30d)
            allTimeHigh       = try? s.decodeIfPresent(Double.self, forKey: .highAllTime)
            allTimeLow        = try? s.decodeIfPresent(Double.self, forKey: .lowAllTime)
        } else {
            price = nil; marketCap = nil; circulatingSupply = nil
            totalSupply = nil; maxSupply = nil; rank = nil
            priceChange1h = nil; priceChange24h = nil
            priceChange7d = nil; priceChange30d = nil
            allTimeHigh = nil; allTimeLow = nil
        }
    }
}

enum ChartTimeRange: String, CaseIterable, Identifiable {
    case oneHour   = "1h"
    case oneDay    = "1d"
    case sevenDays = "7d"
    case oneMonth  = "1m"
    case oneYear   = "1y"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .oneHour:   return "1H"
        case .oneDay:    return "1D"
        case .sevenDays: return "7D"
        case .oneMonth:  return "1M"
        case .oneYear:   return "1Y"
        }
    }

    var apiParam: String { rawValue.uppercased() }
}
