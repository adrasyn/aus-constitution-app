import SwiftUI
import SwiftData

/// A toolbar toggle that bookmarks/un-bookmarks a content item. Reads its own
/// saved state via a scoped @Query.
struct BookmarkButton: View {
    let kind: SavedKind
    let contentID: String

    @Environment(\.modelContext) private var context
    @Query private var matches: [SavedItem]

    init(kind: SavedKind, contentID: String) {
        self.kind = kind
        self.contentID = contentID
        let id = contentID
        let raw = kind.rawValue
        _matches = Query(filter: #Predicate<SavedItem> { $0.contentID == id && $0.kindRaw == raw })
    }

    private var isSaved: Bool { !matches.isEmpty }

    var body: some View {
        Button {
            if let existing = matches.first {
                context.delete(existing)
            } else {
                context.insert(SavedItem(contentID: contentID, kind: kind))
            }
        } label: {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
        }
        .tint(.accentGreen)
        .accessibilityLabel(isSaved ? "Remove bookmark" : "Add bookmark")
    }
}
