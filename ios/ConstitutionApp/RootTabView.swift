import SwiftUI
import ConstitutionKit

struct RootTabView: View {
    let store: ContentStore
    let index: SearchIndex

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
    }
}
