import Foundation

struct FearGreedIndex: Decodable, Sendable {
    let value: Int
    let classification: String
    let timestamp: String

    var sentiment: Sentiment {
        switch value {
        case 0...24: return .extremeFear
        case 25...44: return .fear
        case 45...55: return .neutral
        case 56...74: return .greed
        default:      return .extremeGreed
        }
    }

    enum Sentiment: String {
        case extremeFear  = "Extreme Fear"
        case fear         = "Fear"
        case neutral      = "Neutral"
        case greed        = "Greed"
        case extremeGreed = "Extreme Greed"

        var emoji: String {
            switch self {
            case .extremeFear:  return "😱"
            case .fear:         return "😨"
            case .neutral:      return "😐"
            case .greed:        return "😏"
            case .extremeGreed: return "🤑"
            }
        }
    }
}
