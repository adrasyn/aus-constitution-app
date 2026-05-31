import SwiftUI
import ConstitutionKit

struct ReferendumListView: View {
    let store: ContentStore

    private var referendums: [Referendum] {
        store.referendums.sorted { $0.year < $1.year }
    }

    var body: some View {
        NavigationStack {
            List(referendums) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        HStack(spacing: 6) {
                            Text(String(item.year))
                            Text("·")
                            Text(item.outcome.capitalized)
                            Text("·")
                            Text("\(item.yesPercentage, specifier: "%.1f")% Yes")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Referendums")
            .contentDestinations(store: store)
        }
    }
}
