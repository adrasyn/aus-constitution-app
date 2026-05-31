import SwiftUI
import ConstitutionKit

struct RootTabView: View {
    let store: ContentStore

    var body: some View {
        TabView {
            Tab("Constitution", systemImage: "book") {
                ChapterListView(store: store)
            }
            Tab("Cases", systemImage: "building.columns") {
                PlaceholderView(title: "Cases", systemImage: "building.columns")
            }
            Tab("Referendums", systemImage: "checkmark.seal") {
                PlaceholderView(title: "Referendums", systemImage: "checkmark.seal")
            }
            Tab("Documents", systemImage: "doc.text") {
                PlaceholderView(title: "Documents", systemImage: "doc.text")
            }
            Tab(role: .search) {
                PlaceholderView(title: "Search", systemImage: "magnifyingglass")
            }
        }
    }
}
