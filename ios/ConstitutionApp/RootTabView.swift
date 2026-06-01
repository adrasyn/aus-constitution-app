import SwiftUI
import CoreSpotlight
import ConstitutionKit

struct RootTabView: View {
    let store: ContentStore
    let index: SearchIndex

    @State private var deepLinked: DeepLinkTarget?

    var body: some View {
        TabView {
            Tab("Constitution", systemImage: "book") {
                ChapterListView(store: store)
            }
            Tab("Cases", systemImage: "building.columns") {
                CaseListView(store: store)
            }
            Tab("Referendums", systemImage: "checkmark.seal") {
                ReferendumListView(store: store)
            }
            Tab("Documents", systemImage: "doc.text") {
                DocumentListView(store: store)
            }
            Tab(role: .search) {
                SearchView(store: store, index: index)
            }
        }
        .task {
            SpotlightIndexer.indexIfNeeded(store: store)
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                  let parsed = SpotlightID.parse(identifier) else { return }
            switch parsed.kind {
            case .section:
                if let section = store.section(reference: parsed.id) {
                    deepLinked = .section(section)
                }
            case .legalCase:
                if let legalCase = store.case(id: parsed.id) {
                    deepLinked = .legalCase(legalCase)
                }
            }
        }
        .sheet(item: $deepLinked) { target in
            NavigationStack {
                Group {
                    switch target {
                    case .section(let section):
                        SectionDetailView(store: store, section: section)
                    case .legalCase(let legalCase):
                        CaseDetailView(store: store, legalCase: legalCase)
                    }
                }
                .contentDestinations(store: store)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") { deepLinked = nil }
                    }
                }
            }
        }
    }
}

private enum DeepLinkTarget: Identifiable {
    case section(ConstitutionKit.Section)
    case legalCase(Case)

    var id: String {
        switch self {
        case .section(let s): return SpotlightID.make(kind: .section, id: s.id)
        case .legalCase(let c): return SpotlightID.make(kind: .legalCase, id: c.id)
        }
    }
}
