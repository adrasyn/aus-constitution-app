# Spotlight Indexing — Implementation Plan (Plan 5b)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Index constitution sections and landmark cases into iOS Spotlight, and deep-link from a Spotlight result back into the matching detail screen.

**Architecture:** A pure, testable `SpotlightID` (encode/decode `kind:id`) in `ConstitutionKit`. An app-layer `SpotlightIndexer` builds `CSSearchableItem`s from `ContentStore` and indexes them once per content version. `RootTabView` handles the `CSSearchableItemActionType` user activity, resolves the id via the store, and presents the detail in a sheet.

**Tech Stack:** SwiftUI + CoreSpotlight (iOS 26), Swift Testing, XcodeGen.

**Spec:** `docs/superpowers/specs/2026-05-30-native-ios-app-design.md` §6 (Spotlight).

> **Inherited conventions:** Swift Testing via `cd ios/ConstitutionKit && swift test`. Build on iPhone 17 Pro sim. Branch `plan-5-extras`. `RootTabView(store:index:)` is a plain `TabView` of 5 tabs inside `.modelContainer(for: SavedItem.self)` (so sheets inherit the SwiftData context). `ContentStore.section(reference:)`, `case(id:)`, `sections`, `cases` exist. Detail views: `SectionDetailView(store:section:)`, `CaseDetailView(store:legalCase:)`, both work standalone inside a NavigationStack with `.contentDestinations(store:)`. `Section` → `ConstitutionKit.Section` in app files. No special entitlement is needed for CoreSpotlight indexing or `CSSearchableItemActionType` continuation.

> **Verification:** Task 1 is real `swift test`. The indexer + deep-link are framework integration: gated on `** BUILD SUCCEEDED **` and a clean launch (indexing must not crash); the actual Spotlight search + tap-to-open is validated live by the user (Spotlight isn't scriptable from the harness).

---

## File Structure

```
ios/ConstitutionKit/Sources/ConstitutionKit/SpotlightID.swift          # NEW (testable)
ios/ConstitutionKit/Tests/ConstitutionKitTests/SpotlightIDTests.swift  # NEW
ios/ConstitutionApp/Spotlight/SpotlightIndexer.swift                   # NEW
ios/ConstitutionApp/RootTabView.swift                                  # MODIFY: index on launch + deep-link sheet
```

---

## Task 1: SpotlightID (TDD, ConstitutionKit)

**Files:**
- Create: `ios/ConstitutionKit/Sources/ConstitutionKit/SpotlightID.swift`
- Create: `ios/ConstitutionKit/Tests/ConstitutionKitTests/SpotlightIDTests.swift`

- [ ] **Step 1: Write the failing test:**
```swift
import Testing
@testable import ConstitutionKit

@Suite struct SpotlightIDTests {
    @Test func roundTripsSection() {
        let id = SpotlightID.make(kind: .section, id: "s51")
        #expect(id == "section:s51")
        let parsed = SpotlightID.parse(id)
        #expect(parsed?.kind == .section)
        #expect(parsed?.id == "s51")
    }

    @Test func roundTripsCaseWithHyphens() {
        // Case ids contain hyphens; only the FIRST colon separates kind from id.
        let id = SpotlightID.make(kind: .legalCase, id: "demden-v-pedder-1904")
        #expect(id == "case:demden-v-pedder-1904")
        let parsed = SpotlightID.parse(id)
        #expect(parsed?.kind == .legalCase)
        #expect(parsed?.id == "demden-v-pedder-1904")
    }

    @Test func rejectsUnknownOrMalformed() {
        #expect(SpotlightID.parse("widget:1") == nil)
        #expect(SpotlightID.parse("nocolon") == nil)
    }
}
```

- [ ] **Step 2: Run, verify FAIL**

Run: `cd ios/ConstitutionKit && swift test --filter SpotlightIDTests`
Expected: FAIL — `cannot find 'SpotlightID'`. Report actual.

- [ ] **Step 3: Implement** — `ios/ConstitutionKit/Sources/ConstitutionKit/SpotlightID.swift`:
```swift
import Foundation

/// The content kinds exposed to Spotlight.
public enum SpotlightKind: String, Sendable {
    case section
    case legalCase = "case"
}

/// Encodes/decodes a Spotlight unique identifier as `"<kind>:<id>"`. Content
/// ids may contain hyphens, so decoding splits on the FIRST colon only.
public enum SpotlightID {
    public static func make(kind: SpotlightKind, id: String) -> String {
        "\(kind.rawValue):\(id)"
    }

    public static func parse(_ identifier: String) -> (kind: SpotlightKind, id: String)? {
        let parts = identifier.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2,
              let kind = SpotlightKind(rawValue: String(parts[0])),
              !parts[1].isEmpty
        else { return nil }
        return (kind, String(parts[1]))
    }
}
```

- [ ] **Step 4: Run full suite** — `cd ios/ConstitutionKit && swift test`. Expected: all pass (25 tests). Report the summary line.

- [ ] **Step 5: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionKit
git commit -m "feat(ios): add SpotlightID encode/decode"
```

---

## Task 2: SpotlightIndexer + index on launch

**Files:**
- Create: `ios/ConstitutionApp/Spotlight/SpotlightIndexer.swift`
- Modify: `ios/ConstitutionApp/RootTabView.swift` (trigger indexing)

- [ ] **Step 1: `SpotlightIndexer.swift`:**
```swift
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
```

- [ ] **Step 2: Trigger indexing on launch** in `RootTabView.swift`. Add a `.task` modifier to the `TabView` that runs the indexer (place it after the `TabView { … }` closing brace, alongside other modifiers):
```swift
        .task {
            SpotlightIndexer.indexIfNeeded(store: store)
        }
```

- [ ] **Step 3: Build + launch** (indexing must not crash):
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate
xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
APP=$(find ~/Library/Developer/Xcode/DerivedData -type d -name "ConstitutionApp.app" -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install booted "$APP" 2>/dev/null || true
xcrun simctl launch booted au.constitution.app
sleep 4
xcrun simctl spawn booted launchctl list 2>/dev/null | grep au.constitution.app && echo "RUNNING (indexing OK)" || echo "NOT RUNNING"
```
Expected: `** BUILD SUCCEEDED **` and `RUNNING (indexing OK)`.

- [ ] **Step 4: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Spotlight/SpotlightIndexer.swift ios/ConstitutionApp/RootTabView.swift
git commit -m "feat(ios): index sections and cases into Spotlight on launch"
```

---

## Task 3: Deep-link from Spotlight into a detail sheet

**Files:** Modify `ios/ConstitutionApp/RootTabView.swift`

- [ ] **Step 1: Add deep-link state, sheet, and the activity handler.** Full new `RootTabView.swift`:
```swift
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
```
(The `.task` indexing trigger from Task 2 is now folded into this full file — that's intentional, not a duplicate.)

- [ ] **Step 2: Build + launch.** Standard build + launch (as Task 2 Step 3). Expected: `** BUILD SUCCEEDED **` and the app runs. The deep-link path can't be triggered from the harness; it is validated live by the user.

- [ ] **Step 3: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/RootTabView.swift
git commit -m "feat(ios): open Spotlight results in a detail sheet"
```

---

## Task 4: Verify

- [ ] **Step 1: Unit suite + build**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios/ConstitutionKit && swift test
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate && \
  xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
```
Expected: 25 tests pass; `** BUILD SUCCEEDED **`; app launches and stays running.

- [ ] **Step 2: User validation note.** The controller confirms build + clean launch. The user validates the end-to-end Spotlight flow live: background the app, open Spotlight (swipe down on home screen), search e.g. "Pedder" or "Section 51", tap the result, and confirm the app opens the correct detail in a sheet.

---

## Self-Review (completed during authoring)

- **Spec coverage (§6 Spotlight):** index sections + cases via CoreSpotlight (Task 2) ✓; deep-link back into the right detail via `CSSearchableItemActionType` + `NSUserActivity` (Task 3) ✓; one-time-per-version indexing guard ✓.
- **Placeholder scan:** none — full code throughout; TDD assertions concrete.
- **Type consistency:** `SpotlightID.make/parse` + `SpotlightKind{section,legalCase}` used identically in `SpotlightIndexer`, `RootTabView`'s handler, and `DeepLinkTarget.id`. `RootTabView(store:index:)` signature unchanged. Sheet detail uses existing `SectionDetailView`/`CaseDetailView` initialisers. Test count: 22 + 3 = 25.
- **Decisions/risks:** (1) deep-linked detail is presented as a **sheet** (with Done) rather than pushed into a tab's stack — avoids hoisting all tab navigation state; the sheet's `NavigationStack` + `.contentDestinations` keeps in-detail links working, and `BookmarkButton`'s `@Query` works because SwiftUI propagates the `.modelContainer` to sheets. (2) Spotlight indexing/continuation need no entitlement. (3) The actual Spotlight tap can't be automated here — explicitly deferred to live user validation.
