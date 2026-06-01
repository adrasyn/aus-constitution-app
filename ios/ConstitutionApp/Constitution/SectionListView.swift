import SwiftUI
import ConstitutionKit

struct SectionListView: View {
    let store: ContentStore
    let chapter: Chapter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: chapter.title, subtitle: nil)
                LazyVStack(spacing: 10) {
                    ForEach(store.sections(for: chapter)) { section in
                        NavigationLink(value: section) {
                            ContentCard(accent: .accentGreen) {
                                Text(section.number == "0" ? "Preamble" : "Section \(section.number)")
                                    .font(AppFont.monoSmall)
                                    .foregroundStyle(Color.textSecondary)
                                Text(section.title)
                                    .font(AppFont.cardTitle)
                                    .foregroundStyle(Color.textPrimary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground)
        .revealingNavigationTitle(chapter.title)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
