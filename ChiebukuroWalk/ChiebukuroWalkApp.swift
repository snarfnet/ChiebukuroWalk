import SwiftUI
import SwiftData

@main
struct ChiebukuroWalkApp: App {
    @StateObject private var healthKit = HealthKitManager()
    @StateObject private var storeKit = StoreKitManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(healthKit)
                .environmentObject(storeKit)
                .preferredColorScheme(.light)
        }
        .modelContainer(for: UserProgress.self)
    }
}
