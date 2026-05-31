import SwiftUI
import ConstitutionKit

extension View {
    /// Registers navigation destinations for every content type, so any screen
    /// inside a NavigationStack can `NavigationLink(value:)` to any of them.
    func contentDestinations(store: ContentStore) -> some View {
        self
            .navigationDestination(for: Chapter.self) { chapter in
                SectionListView(store: store, chapter: chapter)
            }
            .navigationDestination(for: ConstitutionKit.Section.self) { section in
                SectionDetailView(store: store, section: section)
            }
            .navigationDestination(for: Case.self) { item in
                CaseDetailView(store: store, legalCase: item)
            }
            .navigationDestination(for: Referendum.self) { item in
                ReferendumDetailView(store: store, referendum: item)
            }
            .navigationDestination(for: HistoricalDocument.self) { item in
                DocumentDetailView(store: store, document: item)
            }
    }
}
