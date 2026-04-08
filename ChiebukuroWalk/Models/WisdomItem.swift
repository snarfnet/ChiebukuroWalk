import Foundation

struct WisdomItem: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let content: String
    let category: String

    var categoryEmoji: String {
        switch category {
        case "料理・食材保存": return "🍳"
        case "掃除・洗濯": return "🧹"
        case "健康・体の手当て": return "💊"
        case "節約・暮らし": return "💰"
        case "季節・行事": return "🎋"
        case "美容・スキンケア": return "✨"
        case "園芸・虫対策": return "🌱"
        case "マナー・人付き合い": return "🎀"
        case "子育て・教育": return "👶"
        case "防災・住まい": return "🏠"
        case "ことわざ・言い伝え": return "📖"
        default: return "💡"
        }
    }
}

let wisdomCategories = [
    "料理・食材保存", "掃除・洗濯", "健康・体の手当て",
    "節約・暮らし", "季節・行事", "美容・スキンケア",
    "園芸・虫対策", "マナー・人付き合い", "子育て・教育",
    "防災・住まい", "ことわざ・言い伝え"
]
