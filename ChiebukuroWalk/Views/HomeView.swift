import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progressList: [UserProgress]
    @EnvironmentObject var healthKit: HealthKitManager
    @EnvironmentObject var storeKit: StoreKitManager
    @State private var showingWisdom: WisdomItem?
    @State private var showingCollection = false
    @State private var showingPremium = false
    @State private var showUnlockAnimation = false

    private var progress: UserProgress {
        if let p = progressList.first { return p }
        let p = UserProgress()
        modelContext.insert(p)
        return p
    }

    private var stepsPerWisdom: Int {
        progress.isPremium ? 1000 : 5000
    }

    private var stepsToNext: Int {
        max(0, stepsPerWisdom - (healthKit.todaySteps - progress.stepsAtLastReset + progress.stepsSinceLastUnlock) % stepsPerWisdom)
    }

    private var canUnlock: Bool {
        let totalSteps = healthKit.todaySteps - progress.stepsAtLastReset
        let wisdomsEarned = totalSteps / stepsPerWisdom
        let wisdomsUnlockedToday = progress.stepsSinceLastUnlock / stepsPerWisdom
        return wisdomsEarned > wisdomsUnlockedToday && progress.totalUnlocked < WisdomManager.shared.totalCount
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerCard
                        stepsCard
                        if canUnlock { unlockButton }
                        statsCard
                        todayWisdomsPreview
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("おばあちゃんの知恵袋ウォーク")
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.darkBrown)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if !progress.isPremium {
                            Button { showingPremium = true } label: {
                                Image(systemName: "star.circle.fill")
                                    .foregroundStyle(AppTheme.gold)
                            }
                        }
                        Button { showingCollection = true } label: {
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(AppTheme.warmBrown)
                        }
                    }
                }
            }
            .sheet(item: $showingWisdom) { wisdom in
                WisdomDetailView(wisdom: wisdom, progress: progress)
            }
            .sheet(isPresented: $showingCollection) {
                CollectionView(progress: progress)
            }
            .sheet(isPresented: $showingPremium) {
                PremiumView(progress: progress)
                    .environmentObject(storeKit)
            }
            .task {
                await healthKit.requestAuthorization()
                healthKit.startObserving()
                await storeKit.loadProduct()
                await storeKit.restorePurchases()
                storeKit.listenForTransactions()
                syncPremiumStatus()
                checkDayReset()
            }
            .onChange(of: storeKit.isPremium) { _, newValue in
                progress.isPremium = newValue
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Text("👵")
                .font(.system(size: 60))
            Text("歩いて知恵を集めよう")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.darkBrown)
            Text(progress.isPremium ? "1,000歩ごとに知恵袋が開きます" : "5,000歩ごとに知恵袋が開きます")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.warmBrown)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.washi)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var stepsCard: some View {
        VStack(spacing: 16) {
            Text("今日の歩数")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.warmBrown)

            Text("\(healthKit.todaySteps)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.darkBrown)

            ProgressView(value: Double(stepsPerWisdom - stepsToNext), total: Double(stepsPerWisdom))
                .tint(AppTheme.softGreen)
                .scaleEffect(y: 2)

            Text("次の知恵袋まで あと\(stepsToNext)歩")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.warmBrown)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppTheme.washi)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var unlockButton: some View {
        Button {
            unlockWisdom()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "gift.fill")
                    .font(.title2)
                Text("知恵袋を開く！")
                    .font(AppTheme.headlineFont)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [AppTheme.warmBrown, AppTheme.gold], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppTheme.warmBrown.opacity(0.3), radius: 8, y: 4)
        }
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(progress.totalUnlocked)", label: "収集済み", icon: "checkmark.circle.fill")
            Divider().frame(height: 40)
            statItem(value: "\(WisdomManager.shared.totalCount - progress.totalUnlocked)", label: "未発見", icon: "questionmark.circle")
            Divider().frame(height: 40)
            statItem(value: "\(Int(progress.completionRate * 100))%", label: "達成率", icon: "chart.pie.fill")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.washi)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.warmBrown)
            Text(value)
                .font(.system(.title3, design: .rounded).bold())
                .foregroundStyle(AppTheme.darkBrown)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.warmBrown)
        }
        .frame(maxWidth: .infinity)
    }

    private var todayWisdomsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近の知恵袋")
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.darkBrown)

            if progress.unlockedIDs.isEmpty {
                Text("まだ知恵袋を開けていません。\n歩いて最初の知恵を手に入れましょう！")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.warmBrown)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                let recentIDs = progress.unlockedIDs.suffix(3).reversed()
                ForEach(Array(recentIDs), id: \.self) { id in
                    if let wisdom = WisdomManager.shared.wisdom(for: id) {
                        Button {
                            showingWisdom = wisdom
                        } label: {
                            wisdomRow(wisdom)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.washi)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func wisdomRow(_ wisdom: WisdomItem) -> some View {
        HStack(spacing: 12) {
            Text(wisdom.categoryEmoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(AppTheme.categoryColor(for: wisdom.category).opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(wisdom.title)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.darkBrown)
                    .lineLimit(1)
                Text(wisdom.category)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.warmBrown)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.tatami)
        }
    }

    private func unlockWisdom() {
        guard let wisdom = WisdomManager.shared.randomUnlockable(excluding: progress.unlockedIDs) else { return }
        progress.unlockedIDs.append(wisdom.id)
        progress.stepsSinceLastUnlock += stepsPerWisdom
        showingWisdom = wisdom
    }

    private func syncPremiumStatus() {
        if storeKit.isPremium {
            progress.isPremium = true
        }
    }

    private func checkDayReset() {
        let today = Calendar.current.startOfDay(for: .now)
        if progress.lastResetDate < today {
            progress.lastResetDate = today
            progress.stepsAtLastReset = 0
            progress.stepsSinceLastUnlock = 0
        }
    }
}
