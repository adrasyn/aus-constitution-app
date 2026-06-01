import SwiftUI
import SwiftData
import ConstitutionKit

struct SavedView: View {
    let store: ContentStore

    @Environment(\.modelContext) private var context
    @Query(sort: \SavedItem.dateAdded, order: .reverse) private var items: [SavedItem]

    private var sections: [ConstitutionKit.Section] {
        items.filter { $0.kind == .section }.compactMap { store.section(reference: $0.contentID) }
    }
    private var cases: [Case] {
        items.filter { $0.kind == .legalCase }.compactMap { store.case(id: $0.contentID) }
    }
    private var referendums: [Referendum] {
        items.filter { $0.kind == .referendum }.compactMap { store.referendum(id: $0.contentID) }
    }
    private var documents: [HistoricalDocument] {
        items.filter { $0.kind == .document }.compactMap { store.document(id: $0.contentID) }
    }

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView(
                    "No saved items",
                    systemImage: "bookmark",
                    description: Text("Tap the bookmark on any section, case, referendum, or document to save it here.")
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        RelatedItemsSection(title: "Sections", items: sections, accent: .accentGreen,
                                            primary: { $0.number == "0" ? "Preamble" : "Section \($0.number)" },
                                            secondary: { $0.title })
                        RelatedItemsSection(title: "Cases", items: cases, accent: .accentGreen,
                                            primary: { $0.shortName ?? $0.name },
                                            secondary: { "\($0.court) · \(String($0.year))" })
                        RelatedItemsSection(title: "Referendums", items: referendums, accent: .accentGold,
                                            primary: { $0.title },
                                            secondary: { "\(String($0.year)) · \($0.outcome.capitalized)" })
                        RelatedItemsSection(title: "Documents", items: documents, accent: .accentGold,
                                            primary: { $0.title },
                                            secondary: { String($0.year) })
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(Color.appBackground)
            }
        }
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
    }
}
