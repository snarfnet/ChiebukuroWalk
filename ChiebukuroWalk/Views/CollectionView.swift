import SwiftUI

struct CollectionView: View {
    let progress: UserProgress
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String?
    @State private var searchText = ""
    @State private var showingWisdom: WisdomItem?
    @State private var showFavoritesOnly = false

    private var displayedWisdoms: [WisdomItem] {
        var items = WisdomManager.shared.allWisdoms
            .filter { progress.isUnlocked($0.id) }

        if showFavoritesOnly {
            items = items.filter { progress.isFavorite($0.id) }
        }
        if let cat = selectedCategory {
            items = items.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            items = items.filter { $0.title.lowercased().contains(q) || $0.content.lowercased().contains(q) }
        }
        return items
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterChip(nil, label: "すべて")
                            filterChip(nil, label: "お気に入り", isFavorite: true)
                            ForEach(wisdomCategories, id: \.self) { cat in
                                filterChip(cat, label: cat)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    // Progress bar
                    VStack(spacing: 4) {
                        ProgressView(value: progress.completionRate)
                            .tint(AppTheme.softGreen)
                        Text("\(progress.totalUnlocked) / \(WisdomManager.shared.totalCount) 収集済み")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.warmBrown)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    if displayedWisdoms.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Text("🔍")
                                .font(.system(size: 50))
                            Text(progress.totalUnlocked == 0 ? "まだ知恵袋がありません\n歩いて集めましょう！" : "該当する知恵袋がありません")
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.warmBrown)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    } else {
                        List(displayedWisdoms) { wisdom in
                            Button {
                                showingWisdom = wisdom
                            } label: {
                                HStack(spacing: 12) {
                                    Text(wisdom.categoryEmoji)
                                        .font(.title3)
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
                                    if progress.isFavorite(wisdom.id) {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(.red)
                                            .font(.caption)
                                    }
                                }
                            }
                            .listRowBackground(AppTheme.washi)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("知恵袋コレクション")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "知恵を検索...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(AppTheme.warmBrown)
                }
            }
            .sheet(item: $showingWisdom) { wisdom in
                WisdomDetailView(wisdom: wisdom, progress: progress)
            }
        }
    }

    private func filterChip(_ category: String?, label: String, isFavorite: Bool = false) -> some View {
        let isSelected = isFavorite ? showFavoritesOnly : (selectedCategory == category && !showFavoritesOnly)
        return Button {
            if isFavorite {
                showFavoritesOnly.toggle()
                if showFavoritesOnly { selectedCategory = nil }
            } else {
                showFavoritesOnly = false
                selectedCategory = selectedCategory == category ? nil : category
            }
        } label: {
            Text(label)
                .font(AppTheme.captionFont)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.warmBrown : AppTheme.washi)
                .foregroundStyle(isSelected ? .white : AppTheme.warmBrown)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.warmBrown.opacity(0.3), lineWidth: 1))
        }
    }
}
