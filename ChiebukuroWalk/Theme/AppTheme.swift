import SwiftUI

enum AppTheme {
    // 和風・おばあちゃんの温かみカラー
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let warmBrown = Color(red: 0.55, green: 0.35, blue: 0.20)
    static let darkBrown = Color(red: 0.35, green: 0.22, blue: 0.12)
    static let tatami = Color(red: 0.76, green: 0.72, blue: 0.50)
    static let softGreen = Color(red: 0.55, green: 0.70, blue: 0.45)
    static let sakura = Color(red: 0.96, green: 0.80, blue: 0.82)
    static let gold = Color(red: 0.85, green: 0.70, blue: 0.30)
    static let washi = Color(red: 0.95, green: 0.93, blue: 0.87)
    static let ink = Color(red: 0.20, green: 0.15, blue: 0.10)

    static let titleFont = Font.system(.title, design: .rounded).bold()
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static func categoryColor(for category: String) -> Color {
        switch category {
        case "料理・食材保存": return Color(red: 0.90, green: 0.50, blue: 0.30)
        case "掃除・洗濯": return Color(red: 0.40, green: 0.65, blue: 0.85)
        case "健康・体の手当て": return Color(red: 0.70, green: 0.85, blue: 0.55)
        case "節約・暮らし": return Color(red: 0.85, green: 0.75, blue: 0.35)
        case "季節・行事": return Color(red: 0.80, green: 0.50, blue: 0.65)
        case "美容・スキンケア": return sakura
        case "園芸・虫対策": return softGreen
        case "マナー・人付き合い": return Color(red: 0.70, green: 0.55, blue: 0.80)
        case "子育て・教育": return Color(red: 0.95, green: 0.70, blue: 0.50)
        case "防災・住まい": return Color(red: 0.60, green: 0.60, blue: 0.65)
        case "ことわざ・言い伝え": return gold
        default: return tatami
        }
    }
}
