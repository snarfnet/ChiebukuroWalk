import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    private let store = HKHealthStore()
    @Published var todaySteps: Int = 0
    @Published var isAuthorized = false

    private let stepType = HKQuantityType(.stepCount)

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: [stepType])
            isAuthorized = true
            await fetchTodaySteps()
        } catch {
            print("HealthKit auth error: \(error)")
        }
    }

    func fetchTodaySteps() async {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .now, options: .strictStartDate)

        do {
            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        let steps = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                        continuation.resume(returning: steps)
                    }
                }
                store.execute(query)
            }
            todaySteps = Int(result)
        } catch {
            print("Step fetch error: \(error)")
        }
    }

    func startObserving() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, _ in
            Task { @MainActor in
                await self?.fetchTodaySteps()
            }
        }
        store.execute(query)
    }
}
