import SwiftUI
import ConstitutionKit

struct CaseListView: View {
    let store: ContentStore

    private var cases: [Case] {
        store.cases.sorted { $0.year < $1.year }
    }

    var body: some View {
        NavigationStack {
            List(cases) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.shortName ?? item.name)
                            .font(.headline)
                        Text("\(item.citation) · \(String(item.year))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Cases")
            .contentDestinations(store: store)
        }
    }
}
