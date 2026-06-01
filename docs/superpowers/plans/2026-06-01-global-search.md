# Global Search — Implementation Plan (Plan 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement global search across all content — sections, cases, referendums, documents — surfaced through the Liquid Glass search tab, with results grouped by type and linking into detail screens.

**Architecture:** A testable `SearchIndex` in `ConstitutionKit` precomputes a lowercased searchable string per item and returns a grouped `SearchResults` for a query (case-insensitive, all-tokens-must-match). The app's `Tab(role: .search)` hosts a `SearchView` using `.searchable`; result groups reuse the existing `RelatedItemsSection` component and navigate via `.contentDestinations`.

**Tech Stack:** Swift 6, SwiftUI (iOS 26), Swift Testing, XcodeGen.

**Spec:** `docs/superpowers/specs/2026-05-30-native-ios-app-design.md` §4.

> **Inherited conventions:** Swift Testing via `cd ios/ConstitutionKit && swift test`. Build/run + screenshot as in prior plans (iPhone 17 Pro simulator). `Section` → `ConstitutionKit.Section` in app files. Existing: `ContentStore` (`sections`, `cases`, `referendums`, `documents`), `RelatedItemsSection(title:items:accent:primary:secondary:)`, `.contentDestinations(store:)`, `Color.*`, `AppFont.*`. `RootTabView` currently takes `let store: ContentStore` and the search tab is a `PlaceholderView`. Models: `Section{id,number(String),title,content}`, `Case{id,name,shortName?,year,court,citation,principle,content}`, `Referendum{id,year,title,question,outcome,content}`, `HistoricalDocument{id,title,year,description,content}`.

---

## File Structure

```
ios/ConstitutionKit/Sources/ConstitutionKit/SearchIndex.swift   # NEW (SearchResults + SearchIndex)
ios/ConstitutionKit/Tests/ConstitutionKitTests/SearchIndexTests.swift  # NEW
ios/ConstitutionApp/Search/SearchView.swift                     # NEW
ios/ConstitutionApp/RootTabView.swift                           # MODIFY: real search tab
ios/ConstitutionApp/ConstitutionApp.swift                       # MODIFY: build SearchIndex once
```

---

## Task 1: SearchIndex + SearchResults (TDD, in ConstitutionKit)

**Files:**
- Create: `ios/ConstitutionKit/Sources/ConstitutionKit/SearchIndex.swift`
- Create: `ios/ConstitutionKit/Tests/ConstitutionKitTests/SearchIndexTests.swift`

- [ ] **Step 1: Write the failing test** — `ios/ConstitutionKit/Tests/ConstitutionKitTests/SearchIndexTests.swift`:
```swift
import Testing
import Foundation
@testable import ConstitutionKit

@Suite struct SearchIndexTests {
    private func makeIndex() throws -> SearchIndex {
        SearchIndex(store: try ContentStore(contentDirectory: repoContentDirectory()))
    }

    @Test func emptyQueryReturnsNothing() throws {
        let index = try makeIndex()
        #expect(index.search("").isEmpty)
        #expect(index.search("   ").isEmpty)
    }

    @Test func findsCaseByName() throws {
        let results = try makeIndex().search("Pedder")
        #expect(results.cases.contains { $0.id == "demden-v-pedder-1904" })
    }

    @Test func findsReferendumByTitle() throws {
        let results = try makeIndex().search("Senate Elections")
        #expect(results.referendums.contains { $0.id == "1906-senate-elections" })
    }

    @Test func findsDocumentByTitleTokens() throws {
        let results = try makeIndex().search("constitution act")
        #expect(results.documents.contains { $0.id == "constitution-act-1900" })
    }

    @Test func findsSections() throws {
        #expect(!(try makeIndex().search("Parliament").sections.isEmpty))
    }

    @Test func allTokensMustMatch() throws {
        // "banana" matches nothing, so the AND semantics exclude the referendum.
        let results = try makeIndex().search("senate banana")
        #expect(!results.referendums.contains { $0.id == "1906-senate-elections" })
    }

    @Test func nonsenseReturnsNothing() throws {
        #expect(try makeIndex().search("qzxnomatchqzx").totalCount == 0)
    }
}
```

- [ ] **Step 2: Run, verify FAIL**

Run: `cd ios/ConstitutionKit && swift test --filter SearchIndexTests`
Expected: FAIL — `cannot find 'SearchIndex' in scope`. Report actual.

- [ ] **Step 3: Implement** — `ios/ConstitutionKit/Sources/ConstitutionKit/SearchIndex.swift`:
```swift
import Foundation

/// Grouped search results, one bucket per content type.
public struct SearchResults: Sendable, Equatable {
    public var sections: [Section] = []
    public var cases: [Case] = []
    public var referendums: [Referendum] = []
    public var documents: [HistoricalDocument] = []

    public var totalCount: Int {
        sections.count + cases.count + referendums.count + documents.count
    }
    public var isEmpty: Bool { totalCount == 0 }
}

/// In-memory full-text-ish search over all content. Built once from a
/// `ContentStore`; precomputes a lowercased searchable string per item.
/// A query matches an item when every whitespace-separated token appears
/// (case-insensitive substring) in that item's searchable text.
public struct SearchIndex: Sendable {
    private let sectionDocs: [(text: String, item: Section)]
    private let caseDocs: [(text: String, item: Case)]
    private let referendumDocs: [(text: String, item: Referendum)]
    private let documentDocs: [(text: String, item: HistoricalDocument)]

    public init(store: ContentStore) {
        sectionDocs = store.sections.map {
            (Self.corpus([$0.title, $0.content, "section \($0.number)"]), $0)
        }
        caseDocs = store.cases.map {
            (Self.corpus([$0.name, $0.shortName ?? "", $0.citation, $0.principle, $0.content]), $0)
        }
        referendumDocs = store.referendums.map {
            (Self.corpus([$0.title, $0.question, $0.content, String($0.year)]), $0)
        }
        documentDocs = store.documents.map {
            (Self.corpus([$0.title, $0.description, $0.content, String($0.year)]), $0)
        }
    }

    public func search(_ query: String) -> SearchResults {
        let tokens = query.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard !tokens.isEmpty else { return SearchResults() }
        func matches(_ text: String) -> Bool { tokens.allSatisfy { text.contains($0) } }
        return SearchResults(
            sections: sectionDocs.filter { matches($0.text) }.map(\.item),
            cases: caseDocs.filter { matches($0.text) }.map(\.item),
            referendums: referendumDocs.filter { matches($0.text) }.map(\.item),
            documents: documentDocs.filter { matches($0.text) }.map(\.item)
        )
    }

    private static func corpus(_ parts: [String]) -> String {
        parts.joined(separator: " ").lowercased()
    }
}
```

- [ ] **Step 4: Run full suite**

Run: `cd ios/ConstitutionKit && swift test`
Expected: all pass (16 tests now). If a content-dependent assertion fails because the real data differs, STOP and report the actual values — do not weaken the test blindly.

- [ ] **Step 5: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionKit
git commit -m "feat(ios): add SearchIndex with grouped results"
```

---

## Task 2: SearchView + wire the search tab

**Files:**
- Create: `ios/ConstitutionApp/Search/SearchView.swift`
- Modify: `ios/ConstitutionApp/RootTabView.swift`
- Modify: `ios/ConstitutionApp/ConstitutionApp.swift`

- [ ] **Step 1: Create `ios/ConstitutionApp/Search/SearchView.swift`:**
```swift
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
```

- [ ] **Step 2: Wire the search tab in `RootTabView.swift`.** Add an `index` property and replace the search-tab placeholder. Full new file:
```swift
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
```

- [ ] **Step 3: Build the index once in `ConstitutionApp.swift`.** Replace the file (keep the existing tab-bar appearance code in `init`):
```swift
import SwiftUI
import ConstitutionKit
import UIKit

@main
struct ConstitutionApp: App {
    let store: ContentStore
    let searchIndex: SearchIndex

    init() {
        let store = ContentStore.bundled()
        self.store = store
        self.searchIndex = SearchIndex(store: store)

        // Shrink only the tab-bar label font; do NOT reconfigure the background,
        // so the iOS 26 Liquid Glass material is preserved.
        let smaller = UIFont.systemFont(ofSize: 9, weight: .medium)
        let attrs: [NSAttributedString.Key: Any] = [.font: smaller]
        let appearance = UITabBar.appearance().standardAppearance
        for layout in [appearance.stackedLayoutAppearance,
                       appearance.inlineLayoutAppearance,
                       appearance.compactInlineLayoutAppearance] {
            layout.normal.titleTextAttributes = attrs
            layout.selected.titleTextAttributes = attrs
        }
        UITabBar.appearance().standardAppearance = appearance
        if let scrollEdge = UITabBar.appearance().scrollEdgeAppearance {
            for layout in [scrollEdge.stackedLayoutAppearance,
                           scrollEdge.inlineLayoutAppearance,
                           scrollEdge.compactInlineLayoutAppearance] {
                layout.normal.titleTextAttributes = attrs
                layout.selected.titleTextAttributes = attrs
            }
            UITabBar.appearance().scrollEdgeAppearance = scrollEdge
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(store: store, index: searchIndex)
                .tint(.accentGreen)
        }
    }
}
```

- [ ] **Step 4: Build**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate
xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
```
Expected: `** BUILD SUCCEEDED **`. (Note: `RelatedItemsSection`'s `secondary` closure returns `String?`; passing a non-optional `String` is fine via the default-param overload — if the compiler objects, wrap as `{ Optional($0.title) }` or adjust to the existing signature.)

- [ ] **Step 5: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp
git commit -m "feat(ios): add global search tab backed by SearchIndex"
```

---

## Task 3: Verify

- [ ] **Step 1: Full build + unit suite**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios/ConstitutionKit && swift test
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate && \
  xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
```
Expected: 16 tests pass; `** BUILD SUCCEEDED **`.

- [ ] **Step 2: CONTROLLER visual check.** Launch, tap the Search tab, type a query (e.g. "trade", "Pedder"), screenshot light + dark, and confirm: the search field appears (Liquid Glass search tab), results are grouped (Sections / Cases / Referendums / Documents), rows are styled cards, and tapping a result navigates to its detail. (Search field typing can be driven with `xcrun simctl io booted` is not possible for taps; the controller may instead temporarily root `SearchView` with a seeded `@State query` to screenshot results, then revert — same technique used for earlier screens.)

---

## Self-Review (completed during authoring)

- **Spec coverage (§4):** global search across all four content types ✓; results grouped by type ✓; case-insensitive token matching over titles/content/citations/etc. ✓; hosted in `Tab(role: .search)` via `.searchable` ✓; in-memory index built once at launch in `ConstitutionKit` ✓; results navigate into detail via `.contentDestinations` ✓.
- **Placeholder scan:** none — full code in every step; TDD assertions use concrete known ids.
- **Type consistency:** `SearchIndex(store:)`, `SearchResults{sections,cases,referendums,documents,totalCount,isEmpty}`, `SearchView(store:index:)`, `RootTabView(store:index:)` and `ConstitutionApp` building `searchIndex` all line up. `RelatedItemsSection(title:items:accent:primary:secondary:)` reused exactly as defined in the rollout plan. Test count: 9 existing + 7 new = 16.
- **Risk flag:** the `RelatedItemsSection.secondary` parameter is typed `(Item) -> String?` with a default; the call sites pass a `String`-returning closure, which type-checks as `String?`. Step 4 notes the fallback if the compiler is strict.
