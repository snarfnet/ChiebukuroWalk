import Foundation

class WisdomManager {
    static let shared = WisdomManager()
    let allWisdoms: [WisdomItem]

    private init() {
        guard let url = Bundle.main.url(forResource: "wisdom_data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([WisdomItem].self, from: data) else {
            allWisdoms = []
            return
        }
        allWisdoms = items
    }

    var totalCount: Int { allWisdoms.count }

    func wisdom(for id: Int) -> WisdomItem? {
        allWisdoms.first { $0.id == id }
    }

    func wisdoms(in category: String) -> [WisdomItem] {
        allWisdoms.filter { $0.category == category }
    }

    func randomUnlockable(excluding unlocked: [Int]) -> WisdomItem? {
        let available = allWisdoms.filter { !unlocked.contains($0.id) }
        return available.randomElement()
    }

    func search(_ query: String) -> [WisdomItem] {
        let q = query.lowercased()
        return allWisdoms.filter {
            $0.title.lowercased().contains(q) || $0.content.lowercased().contains(q)
        }
    }
}
