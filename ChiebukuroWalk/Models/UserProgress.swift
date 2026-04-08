import Foundation
import SwiftData

@Model
final class UserProgress {
    var unlockedIDs: [Int]
    var favoriteIDs: [Int]
    var lastResetDate: Date
    var stepsAtLastReset: Int
    var stepsSinceLastUnlock: Int
    var isPremium: Bool

    init() {
        self.unlockedIDs = []
        self.favoriteIDs = []
        self.lastResetDate = Calendar.current.startOfDay(for: .now)
        self.stepsAtLastReset = 0
        self.stepsSinceLastUnlock = 0
        self.isPremium = false
    }

    var stepsPerWisdom: Int {
        isPremium ? 1000 : 5000
    }

    func isUnlocked(_ id: Int) -> Bool {
        unlockedIDs.contains(id)
    }

    func isFavorite(_ id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(_ id: Int) {
        if favoriteIDs.contains(id) {
            favoriteIDs.removeAll { $0 == id }
        } else {
            favoriteIDs.append(id)
        }
    }

    var totalUnlocked: Int { unlockedIDs.count }
    var completionRate: Double { Double(unlockedIDs.count) / 2000.0 }
}
