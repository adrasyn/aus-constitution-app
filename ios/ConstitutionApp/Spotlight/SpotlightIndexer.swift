import Foundation
import CoreSpotlight
import UniformTypeIdentifiers
import ConstitutionKit

/// Indexes sections and cases into Spotlight, once per content version.
enum SpotlightIndexer {
    private static let versionKey = "spotlightIndexVersion"
    private static let currentVersion = 1

    static func indexIfNeeded(store: ContentStore) {
        guard UserDefaults.standard.integer(forKey: versionKey) != currentVersion else { return }

        var items: [CSSearchableItem] = []

        for s in store.sections {
            let attrs = CSSearchableItemAttributeSet(contentType: .text)
            attrs.title = s.number == "0" ? "Preamble" : "Section \(s.number): \(s.title)"
            attrs.contentDescription = String(s.content.prefix(200))
            attrs.keywords = ["constitution", "section", s.title]
            items.append(CSSearchableItem(
                uniqueIdentifier: SpotlightID.make(kind: .section, id: s.id),
                domainIdentifier: "au.constitution.section",
                attributeSet: attrs))
        }

        for c in store.cases {
            let attrs = CSSearchableItemAttributeSet(contentType: .text)
            attrs.title = c.name
            attrs.contentDescription = "\(c.citation) — \(c.principle)"
            attrs.keywords = ["constitution", "case", c.shortName ?? c.name]
            items.append(CSSearchableItem(
                uniqueIdentifier: SpotlightID.make(kind: .legalCase, id: c.id),
                domainIdentifier: "au.constitution.case",
                attributeSet: attrs))
        }

        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if error == nil {
                UserDefaults.standard.set(currentVersion, forKey: versionKey)
            }
        }
    }
}
