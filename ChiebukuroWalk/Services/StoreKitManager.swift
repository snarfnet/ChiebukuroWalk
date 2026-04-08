import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var isPremium = false
    @Published var product: Product?

    static let productID = "com.chiebukurowalk.premium"

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            print("Product load error: \(error)")
        }
    }

    func purchase() async -> Bool {
        guard let product else { return false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    isPremium = true
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase error: \(error)")
        }
        return false
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID {
                isPremium = true
            }
        }
    }

    func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   transaction.productID == Self.productID {
                    isPremium = true
                    await transaction.finish()
                }
            }
        }
    }
}
