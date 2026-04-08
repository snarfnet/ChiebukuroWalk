import SwiftUI

struct WisdomDetailView: View {
    let wisdom: WisdomItem
    let progress: UserProgress
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Category badge
                        HStack {
                            Text(wisdom.categoryEmoji)
                            Text(wisdom.category)
                                .font(AppTheme.captionFont)
                        }
                        .foregroundStyle(AppTheme.warmBrown)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.categoryColor(for: wisdom.category).opacity(0.15))
                        .clipShape(Capsule())

                        // Title
                        Text(wisdom.title)
                            .font(.system(.title2, design: .rounded).bold())
                            .foregroundStyle(AppTheme.darkBrown)
                            .multilineTextAlignment(.center)

                        // Divider
                        HStack {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle().fill(AppTheme.tatami).frame(width: 6, height: 6)
                            }
                        }

                        // Content
                        Text(wisdom.content)
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.ink)
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(AppTheme.washi)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Wisdom number
                        Text("知恵袋 No.\(wisdom.id)")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.tatami)
                    }
                    .padding(24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(AppTheme.warmBrown)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        progress.toggleFavorite(wisdom.id)
                    } label: {
                        Image(systemName: progress.isFavorite(wisdom.id) ? "heart.fill" : "heart")
                            .foregroundStyle(progress.isFavorite(wisdom.id) ? .red : AppTheme.warmBrown)
                    }
                }
            }
        }
    }
}
