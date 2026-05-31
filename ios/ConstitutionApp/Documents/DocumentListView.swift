import SwiftUI
import ConstitutionKit

struct DocumentListView: View {
    let store: ContentStore
    private var documents: [HistoricalDocument] { store.documents.sorted { $0.year < $1.year } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Documents", subtitle: "\(store.documents.count) foundational documents")
                    LazyVStack(spacing: 10) {
                        ForEach(documents) { item in
                            NavigationLink(value: item) {
                                ContentCard(accent: .accentGold) {
                                    YearBadge(text: String(item.year))
                                    Text(item.title)
                                        .font(AppFont.cardTitle)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(item.description)
                                        .font(AppFont.body)
                                        .foregroundStyle(Color.textSecondary)
                                        .lineLimit(3)
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
            .navigationTitle("Documents")
            .navigationBarTitleDisplayMode(.inline)
            .contentDestinations(store: store)
        }
    }
}
