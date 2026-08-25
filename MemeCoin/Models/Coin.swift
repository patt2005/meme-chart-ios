import Foundation

struct Coin: Identifiable, Codable, Sendable {
    let id: Int
    let name: String
    let symbol: String
    let slug: String
    let rank: Int?
    let marketCap: Double?
    let price: Double?
    let priceChange1h: Double?
    let priceChange24h: Double?
    let priceChange7d: Double?
    let volume24h: Double?
    var logoURLOverride: String?

    var logoURL: String? {
        if let override = logoURLOverride, !override.isEmpty { return override }
        return id > 0 ? "https://s2.coinmarketcap.com/static/img/coins/128x128/\(id).png" : nil
    }

    init(id: Int, name: String, symbol: String, slug: String, rank: Int?,
         marketCap: Double?, price: Double?, priceChange1h: Double?,
         priceChange24h: Double?, priceChange7d: Double?, volume24h: Double?,
         logoURLOverride: String? = nil) {
        self.id = id; self.name = name; self.symbol = symbol; self.slug = slug
        self.rank = rank; self.marketCap = marketCap; self.price = price
        self.priceChange1h = priceChange1h; self.priceChange24h = priceChange24h
        self.priceChange7d = priceChange7d; self.volume24h = volume24h
        self.logoURLOverride = logoURLOverride
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug, rank, marketCap, volume24h
        case price, priceChange1h, priceChange24h, priceChange7d
        case logoURLOverride
        case cmcRank, quotes, priceChange
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = try c.decode(Int.self,    forKey: .id)
        name   = try c.decode(String.self, forKey: .name)
        symbol = try c.decode(String.self, forKey: .symbol)
        slug   = try c.decode(String.self, forKey: .slug)

        logoURLOverride = try? c.decodeIfPresent(String.self, forKey: .logoURLOverride)

        rank = (try? c.decodeIfPresent(Int.self, forKey: .rank))
            ?? (try? c.decodeIfPresent(Int.self, forKey: .cmcRank))

        if let pc = try? c.nestedContainer(keyedBy: PriceChangeKeys.self, forKey: .priceChange) {
            price          = try? pc.decodeIfPresent(Double.self, forKey: .price)
            volume24h      = try? pc.decodeIfPresent(Double.self, forKey: .volume24h)
            priceChange1h  = try? pc.decodeIfPresent(Double.self, forKey: .priceChange1h)
            priceChange24h = try? pc.decodeIfPresent(Double.self, forKey: .priceChange24h)
            priceChange7d  = try? pc.decodeIfPresent(Double.self, forKey: .priceChange7d)
            marketCap      = try? c.decodeIfPresent(Double.self, forKey: .marketCap)
        } else if let qc = try? c.nestedContainer(keyedBy: QuoteKeys.self, forKey: .quotes),
                  let uc = try? qc.nestedContainer(keyedBy: USDKeys.self, forKey: .USD) {
            price          = try? uc.decodeIfPresent(Double.self, forKey: .price)
            marketCap      = try? uc.decodeIfPresent(Double.self, forKey: .marketCap)
            volume24h      = try? uc.decodeIfPresent(Double.self, forKey: .volume24h)
            priceChange1h  = try? uc.decodeIfPresent(Double.self, forKey: .percentChange1h)
            priceChange24h = try? uc.decodeIfPresent(Double.self, forKey: .percentChange24h)
            priceChange7d  = try? uc.decodeIfPresent(Double.self, forKey: .percentChange7d)
        } else {
            price          = try? c.decodeIfPresent(Double.self, forKey: .price)
            marketCap      = try? c.decodeIfPresent(Double.self, forKey: .marketCap)
            volume24h      = try? c.decodeIfPresent(Double.self, forKey: .volume24h)
            priceChange1h  = try? c.decodeIfPresent(Double.self, forKey: .priceChange1h)
            priceChange24h = try? c.decodeIfPresent(Double.self, forKey: .priceChange24h)
            priceChange7d  = try? c.decodeIfPresent(Double.self, forKey: .priceChange7d)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,     forKey: .id)
        try c.encode(name,   forKey: .name)
        try c.encode(symbol, forKey: .symbol)
        try c.encode(slug,   forKey: .slug)
        try c.encodeIfPresent(rank,          forKey: .rank)
        try c.encodeIfPresent(price,         forKey: .price)
        try c.encodeIfPresent(marketCap,     forKey: .marketCap)
        try c.encodeIfPresent(volume24h,     forKey: .volume24h)
        try c.encodeIfPresent(priceChange1h,  forKey: .priceChange1h)
        try c.encodeIfPresent(priceChange24h, forKey: .priceChange24h)
        try c.encodeIfPresent(priceChange7d,   forKey: .priceChange7d)
        try c.encodeIfPresent(logoURLOverride, forKey: .logoURLOverride)
    }

    private enum PriceChangeKeys: String, CodingKey {
        case price, volume24h
        case priceChange1h, priceChange24h, priceChange7d
    }

    private enum QuoteKeys: String, CodingKey { case USD }

    private enum USDKeys: String, CodingKey {
        case price, marketCap, volume24h
        case percentChange1h, percentChange24h, percentChange7d
    }
}
