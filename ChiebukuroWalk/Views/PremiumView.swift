import SwiftUI

struct PremiumView: View {
    let progress: UserProgress
    @EnvironmentObject var storeKit: StoreKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [AppTheme.cream, AppTheme.sakura.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Text("👵✨")
                            .font(.system(size: 80))
                            .padding(.top, 20)

                        Text("プレミアム版")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .foregroundStyle(AppTheme.darkBrown)

                        Text("もっとたくさんの知恵を集めよう！")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.warmBrown)

                        // Comparison
                        VStack(spacing: 16) {
                            comparisonRow(free: "5,000歩で1つ", premium: "1,000歩で1つ")
                            comparisonRow(free: "1日 1〜2個", premium: "1日 6〜7個")
                            comparisonRow(free: "コンプまで約4年", premium: "コンプまで約10ヶ月")
                        }
                        .padding(20)
                        .background(AppTheme.washi)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        if progress.isPremium {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(AppTheme.softGreen)
                                Text("プレミアム購入済み")
                                    .font(AppTheme.headlineFont)
                                    .foregroundStyle(AppTheme.softGreen)
                            }
                            .padding()
                        } else {
                            // Purchase button
                            Button {
                                Task {
                                    isPurchasing = true
                                    let success = await storeKit.purchase()
                                    if success {
                                        progress.isPremium = true
                                    }
                                    isPurchasing = false
                                }
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("\(storeKit.product?.displayPrice ?? "¥120") で購入")
                                            .font(AppTheme.headlineFont)
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [AppTheme.gold, AppTheme.warmBrown], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(isPurchasing || storeKit.product == nil)

                            Button("購入を復元") {
                                Task { await storeKit.restorePurchases()
                                    if storeKit.isPremium { progress.isPremium = true }
                                }
                            }
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.warmBrown)
                        }
                    }
                    .padding(24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(AppTheme.warmBrown)
                }
            }
        }
    }

    private func comparisonRow(free: String, premium: String) -> some View {
        HStack {
            VStack {
                Text("無料版")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.warmBrown)
                Text(free)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.ink)
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "arrow.right")
                .foregroundStyle(AppTheme.gold)

            VStack {
                Text("プレミアム")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.gold)
                Text(premium)
                    .font(AppTheme.bodyFont.bold())
                    .foregroundStyle(AppTheme.darkBrown)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
