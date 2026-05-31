import SwiftUI
import ConstitutionKit

struct ChapterListView: View {
    let store: ContentStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Constitution",
                                 subtitle: "Commonwealth of Australia Constitution Act 1900")
                    LazyVStack(spacing: 10) {
                        ForEach(store.chapters) { chapter in
                            let count = store.sections(for: chapter).count
                            NavigationLink(value: chapter) {
                                ContentCard(accent: .accentGreen) {
                                    Text(chapter.title)
                                        .font(AppFont.cardTitle)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(count == 1 ? "1 section" : "\(count) sections")
                                        .font(AppFont.monoSmall)
                                        .foregroundStyle(Color.textSecondary)
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
            .navigationTitle("Constitution")
            .navigationBarTitleDisplayMode(.inline)
            .contentDestinations(store: store)
        }
    }
}
