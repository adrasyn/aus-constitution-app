import SwiftUI
import ConstitutionKit

struct DocumentListView: View {
    let store: ContentStore

    private var documents: [HistoricalDocument] {
        store.documents.sorted { $0.year < $1.year }
    }

    var body: some View {
        NavigationStack {
            List(documents) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text(String(item.year))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Documents")
            .contentDestinations(store: store)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
    }
}
