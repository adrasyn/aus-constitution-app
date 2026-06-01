# Saved & Share — Implementation Plan (Plan 4)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users bookmark any content (sections, cases, referendums, documents) with on-device SwiftData persistence, browse them from a Saved list opened via a bookmark button on the Constitution home, and share any item via the iOS share sheet.

**Architecture:** Pure share-text formatting lives in `ConstitutionKit` (testable). A SwiftData `@Model SavedItem` persists `(contentID, kind, dateAdded)`; a reusable `BookmarkButton` (using `@Query` + `modelContext`) toggles saved state from detail toolbars, which also host a `ShareLink`. `SavedView` resolves saved items back to content via `ContentStore`, grouped by type, and is pushed from the Constitution stack (reusing its `.contentDestinations`).

**Tech Stack:** Swift 6, SwiftUI + SwiftData (iOS 26), Swift Testing, XcodeGen.

**Spec:** `docs/superpowers/specs/2026-05-30-native-ios-app-design.md` §5–6.

> **Inherited conventions:** Swift Testing via `cd ios/ConstitutionKit && swift test`. Build/screenshot on iPhone 17 Pro sim. `Section` → `ConstitutionKit.Section` in app files. Existing: `ContentStore` (`section(reference:)`, `case(id:)`, `referendum(id:)`, `document(id:)`, `sections/cases/referendums/documents`), `ContentCard`, `RelatedItemsSection`, `AppFont`, `Color.*`, `.contentDestinations(store:)`, `.revealingNavigationTitle(_:)`. `RootTabView(store:index:)`; detail views: `SectionDetailView(store:section:)` (has computed `label`), `CaseDetailView(store:legalCase:)`, `ReferendumDetailView(store:referendum:)`, `DocumentDetailView(store:document:)`. Models per earlier plans.

---

## File Structure

```
ios/ConstitutionKit/Sources/ConstitutionKit/ShareText.swift          # NEW (testable)
ios/ConstitutionKit/Tests/ConstitutionKitTests/ShareTextTests.swift  # NEW
ios/ConstitutionApp/Saved/SavedItem.swift                            # NEW (@Model + SavedKind)
ios/ConstitutionApp/Saved/BookmarkButton.swift                       # NEW
ios/ConstitutionApp/Saved/SavedView.swift                            # NEW
ios/ConstitutionApp/ConstitutionApp.swift                            # MODIFY: .modelContainer
ios/ConstitutionApp/Constitution/ChapterListView.swift               # MODIFY: Saved toolbar button
ios/ConstitutionApp/Constitution/SectionDetailView.swift             # MODIFY: toolbar (share + bookmark)
ios/ConstitutionApp/Cases/CaseDetailView.swift                       # MODIFY: toolbar
ios/ConstitutionApp/Referendums/ReferendumDetailView.swift           # MODIFY: toolbar
ios/ConstitutionApp/Documents/DocumentDetailView.swift               # MODIFY: toolbar
```

> **Verification:** Task 1 is real `swift test`. SwiftData/UI tasks are gated on `** BUILD SUCCEEDED **` + controller screenshots (a detail screen's share/bookmark toolbar; the Saved list seeded with items). Full interaction (tap-to-bookmark) confirmed live by the user.

---

## Task 1: ShareText (TDD, ConstitutionKit)

**Files:**
- Create: `ios/ConstitutionKit/Sources/ConstitutionKit/ShareText.swift`
- Create: `ios/ConstitutionKit/Tests/ConstitutionKitTests/ShareTextTests.swift`

- [ ] **Step 1: Write the failing test:**
```swift
import Testing
import Foundation
@testable import ConstitutionKit

@Suite struct ShareTextTests {
    private func store() throws -> ContentStore {
        try ContentStore(contentDirectory: repoContentDirectory())
    }

    @Test func sectionShareIncludesLabelTitleAttribution() throws {
        let s = try #require(try store().section(id: "s51"))
        let text = ShareText.section(s)
        #expect(text.contains("Section 51"))
        #expect(text.contains(s.title))
        #expect(text.contains("Australian Constitution"))
    }

    @Test func preambleSharesAsPreamble() throws {
        let s = try #require(try store().section(id: "s0"))
        #expect(ShareText.section(s).contains("Preamble"))
    }

    @Test func caseShareIncludesNameAndCitation() throws {
        let c = try #require(try store().case(id: "demden-v-pedder-1904"))
        let text = ShareText.legalCase(c)
        #expect(text.contains(c.name))
        #expect(text.contains(c.citation))
    }

    @Test func referendumShareIncludesTitleAndYear() throws {
        let r = try #require(try store().referendum(id: "1906-senate-elections"))
        let text = ShareText.referendum(r)
        #expect(text.contains(r.title))
        #expect(text.contains("1906"))
    }

    @Test func documentShareIncludesTitle() throws {
        let d = try #require(try store().document(id: "constitution-act-1900"))
        #expect(ShareText.document(d).contains(d.title))
    }

    @Test func excerptIsTruncated() throws {
        let s = try #require(try store().section(id: "s51"))
        // Long content is excerpted, so the share text stays well under the full length.
        #expect(ShareText.section(s).count < s.content.count + 200)
    }
}
```

- [ ] **Step 2: Run, verify FAIL**

Run: `cd ios/ConstitutionKit && swift test --filter ShareTextTests`
Expected: FAIL — `cannot find 'ShareText'`. Report actual.

- [ ] **Step 3: Implement** — `ios/ConstitutionKit/Sources/ConstitutionKit/ShareText.swift`:
```swift
import Foundation

/// Formats content items into shareable plain text (title, key metadata, an
/// excerpt, and attribution).
public enum ShareText {
    private static let attribution = "— Australian Constitution"
    private static let excerptLimit = 280

    public static func section(_ s: Section) -> String {
        let label = s.number == "0" ? "Preamble" : "Section \(s.number)"
        return "\(label) — \(s.title)\n\n\(excerpt(s.content))\n\n\(attribution)"
    }

    public static func legalCase(_ c: Case) -> String {
        "\(c.name)\n\(c.citation) · \(c.court), \(c.year)\n\n\(excerpt(c.principle))\n\n\(attribution)"
    }

    public static func referendum(_ r: Referendum) -> String {
        "\(r.title) (\(r.year)) — \(r.outcome.capitalized)\n\n\(excerpt(r.question))\n\n\(attribution)"
    }

    public static func document(_ d: HistoricalDocument) -> String {
        "\(d.title) (\(d.year))\n\n\(excerpt(d.description))\n\n\(attribution)"
    }

    private static func excerpt(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > excerptLimit else { return trimmed }
        let end = trimmed.index(trimmed.startIndex, offsetBy: excerptLimit)
        return trimmed[..<end].trimmingCharacters(in: .whitespaces) + "…"
    }
}
```

- [ ] **Step 4: Run full suite** — `cd ios/ConstitutionKit && swift test`. Expected: all pass (22 tests). Report the summary line.

- [ ] **Step 5: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionKit
git commit -m "feat(ios): add ShareText formatting for content sharing"
```

---

## Task 2: SwiftData model + container

**Files:**
- Create: `ios/ConstitutionApp/Saved/SavedItem.swift`
- Modify: `ios/ConstitutionApp/ConstitutionApp.swift`

- [ ] **Step 1: `SavedItem.swift`:**
```swift
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
```

- [ ] **Step 2: Attach the model container** in `ConstitutionApp.swift`. Add `import SwiftData` at the top, and add the `.modelContainer` modifier to the scene's root. Change the `body`:
```swift
    var body: some Scene {
        WindowGroup {
            RootTabView(store: store, index: searchIndex)
                .tint(.accentGreen)
                .modelContainer(for: SavedItem.self)
        }
    }
```
(Leave the `init()` with the tab-bar appearance + index building unchanged. Just add `import SwiftData` and the modifier.)

- [ ] **Step 3: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Saved/SavedItem.swift ios/ConstitutionApp/ConstitutionApp.swift
git commit -m "feat(ios): add SavedItem SwiftData model and container"
```

---

## Task 3: BookmarkButton + detail toolbars (bookmark + share)

**Files:**
- Create: `ios/ConstitutionApp/Saved/BookmarkButton.swift`
- Modify: the four detail views (add a trailing toolbar with share + bookmark)

- [ ] **Step 1: `BookmarkButton.swift`:**
```swift
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
```

- [ ] **Step 2: Add a trailing toolbar to each detail view.** In each of the four detail views, add this modifier on the `ScrollView` (after the existing `.tabBarMinimizeBehavior(.onScrollDown)`), using that view's item:

`SectionDetailView` (uses `section`, kind `.section`):
```swift
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: ShareText.section(section)) {
                    Image(systemName: "square.and.arrow.up")
                }
                BookmarkButton(kind: .section, contentID: section.id)
            }
        }
```
`CaseDetailView` (uses `legalCase`, kind `.legalCase`):
```swift
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: ShareText.legalCase(legalCase)) {
                    Image(systemName: "square.and.arrow.up")
                }
                BookmarkButton(kind: .legalCase, contentID: legalCase.id)
            }
        }
```
`ReferendumDetailView` (uses `referendum`, kind `.referendum`):
```swift
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: ShareText.referendum(referendum)) {
                    Image(systemName: "square.and.arrow.up")
                }
                BookmarkButton(kind: .referendum, contentID: referendum.id)
            }
        }
```
`DocumentDetailView` (uses `document`, kind `.document`):
```swift
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: ShareText.document(document)) {
                    Image(systemName: "square.and.arrow.up")
                }
                BookmarkButton(kind: .document, contentID: document.id)
            }
        }
```
Each detail view already `import ConstitutionKit` (for `ShareText`). Add `import SwiftData` is NOT needed in the detail views (BookmarkButton encapsulates it). The `.revealingNavigationTitle` already adds a principal toolbar item; a second `.toolbar` composes fine.

- [ ] **Step 3: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`. If `ToolbarItemGroup`'s two `@Query`-driven buttons cause an "init in toolbar" issue, confirm `BookmarkButton` is a standalone `View` (it is) — that resolves it.

- [ ] **Step 4: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Saved/BookmarkButton.swift ios/ConstitutionApp/Constitution/SectionDetailView.swift ios/ConstitutionApp/Cases/CaseDetailView.swift ios/ConstitutionApp/Referendums/ReferendumDetailView.swift ios/ConstitutionApp/Documents/DocumentDetailView.swift
git commit -m "feat(ios): add bookmark toggle and share to detail toolbars"
```

---

## Task 4: SavedView + entry point on Constitution home

**Files:**
- Create: `ios/ConstitutionApp/Saved/SavedView.swift`
- Modify: `ios/ConstitutionApp/Constitution/ChapterListView.swift`

- [ ] **Step 1: `SavedView.swift`:**
```swift
import SwiftUI
import SwiftData
import ConstitutionKit

struct SavedView: View {
    let store: ContentStore

    @Environment(\.modelContext) private var context
    @Query(sort: \SavedItem.dateAdded, order: .reverse) private var items: [SavedItem]

    private var sections: [Section] {
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
```

(Removal is done by opening an item and tapping its filled bookmark — keeps `SavedView` read-only and consistent with the card styling. Swipe-to-delete would require a `List`, which we're intentionally avoiding.)

- [ ] **Step 2: Add the Saved entry button to `ChapterListView`.** Add a trailing toolbar item that pushes `SavedView` (the Constitution `NavigationStack` already has `.contentDestinations`, so saved items navigate correctly). Add this modifier to the `ScrollView`, after `.contentDestinations(store: store)`:
```swift
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SavedView(store: store)
                    } label: {
                        Image(systemName: "bookmark")
                    }
                    .tint(.accentGreen)
                }
            }
```

- [ ] **Step 3: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Saved/SavedView.swift ios/ConstitutionApp/Constitution/ChapterListView.swift
git commit -m "feat(ios): add Saved list and Constitution home entry point"
```

---

## Task 5: Verify

- [ ] **Step 1: Unit suite + build**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios/ConstitutionKit && swift test
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate && \
  xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
```
Expected: 22 tests pass; `** BUILD SUCCEEDED **`.

- [ ] **Step 2: CONTROLLER visual check.** Launch the app. Confirm: (a) a detail screen shows the **share** and **bookmark** icons top-right; tapping the bookmark fills it; (b) the Constitution home shows a **bookmark** button top-right that opens the Saved list; (c) after bookmarking an item, it appears in Saved (grouped), and tapping it opens the detail; (d) sharing opens the iOS share sheet with formatted text. (Taps aren't scriptable; the controller may temporarily seed `SavedItem`s and/or root individual views to screenshot, then revert — as with earlier screens. The user confirms full tap interaction live.)

---

## Self-Review (completed during authoring)

- **Spec coverage (§5–6):** bookmark anything — sections/cases/referendums/documents (Task 3, `SavedKind` 4 cases) ✓; on-device SwiftData persistence (`SavedItem` + `.modelContainer`, Tasks 2) ✓; Saved list opened from a **bookmark button on the Constitution home**, grouped by type, resolving to live content (Task 4) ✓; bookmark toggle on every detail screen (Task 3) ✓; **share sheet** via `ShareLink` with formatted text (Tasks 1, 3) ✓.
- **Placeholder scan:** none — full code throughout; TDD assertions use concrete ids.
- **Type consistency:** `SavedKind{section,legalCase,referendum,document}`, `SavedItem(contentID:kind:dateAdded:)` + `kindRaw`/`kind`, `BookmarkButton(kind:contentID:)`, `ShareText.{section,legalCase,referendum,document}` match every call site. Detail views pass their own ids/items and the matching `kind`. `SavedView` uses `RelatedItemsSection` exactly as defined. Test count: 16 + 6 = 22.
- **Decisions noted:** removal is via the detail bookmark toggle (SavedView stays card-styled, no `List`); `BookmarkButton` is a standalone view so its scoped `@Query` is valid inside a toolbar.
- **Risk flag:** `#Predicate` comparing `kindRaw` (String) avoids enum-in-predicate limitations. If `@Query` inside a `ToolbarItemGroup` misbehaves, the fallback is to compute saved-state in the parent and pass a binding — noted for the build step.
