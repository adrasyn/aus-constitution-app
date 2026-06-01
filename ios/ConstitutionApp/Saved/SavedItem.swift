import Foundation
import SwiftData

/// The kind of content a bookmark points at.
enum SavedKind: String, Codable, CaseIterable {
    case section, legalCase, referendum, document
}

/// A bookmarked content item, persisted on-device with SwiftData.
@Model
final class SavedItem {
    var contentID: String
    var kindRaw: String
    var dateAdded: Date

    init(contentID: String, kind: SavedKind, dateAdded: Date = .now) {
        self.contentID = contentID
        self.kindRaw = kind.rawValue
        self.dateAdded = dateAdded
    }

    var kind: SavedKind { SavedKind(rawValue: kindRaw) ?? .section }
}
