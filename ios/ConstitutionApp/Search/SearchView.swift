import SwiftUI
import ConstitutionKit

struct SearchView: View {
    let store: ContentStore
    let index: SearchIndex
    @State private var query = ""

    private var results: SearchResults { index.search(query) }

    var body: some View {
        NavigationStack {
            Group {
                if query.trimmingCharacters(in: .whitespaces).isEmpty {
                    ContentUnavailableView(
                        "Search",
                        systemImage: "magnifyingglass",
                        description: Text("Find sections, cases, referendums, and documents.")
                    )
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            RelatedItemsSection(
                                title: "Sections", items: results.sections, accent: .accentGreen,
                                primary: { $0.number == "0" ? "Preamble" : "Section \($0.number)" },
                                secondary: { $0.title }
                            )
                            RelatedItemsSection(
                                title: "Cases", items: results.cases, accent: .accentGreen,
                                primary: { $0.shortName ?? $0.name },
                                secondary: { "\($0.court) · \(String($0.year))" }
                            )
                            RelatedItemsSection(
                                title: "Referendums", items: results.referendums, accent: .accentGold,
                                primary: { $0.title },
                                secondary: { "\(String($0.year)) · \($0.outcome.capitalized)" }
                            )
                            RelatedItemsSection(
                                title: "Documents", items: results.documents, accent: .accentGold,
                                primary: { $0.title },
                                secondary: { String($0.year) }
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .background(Color.appBackground)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search the Constitution")
            .contentDestinations(store: store)
        }
    }
}
