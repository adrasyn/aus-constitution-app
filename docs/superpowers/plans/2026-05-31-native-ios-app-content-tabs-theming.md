# Native iOS App — Plan 2: Content Tabs, Cross-Navigation & Theming

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Cases, Referendums, and Documents tabs with detail screens, wire up cross-type navigation between all content, and apply the parchment light/dark theme.

**Architecture:** Each tab is a `NavigationStack` that shares one set of `navigationDestination`s (a reusable `.contentDestinations(store:)` modifier) so any content type can link to any other. Related-item lists use one generic `RelatedSection` component. Theming is an asset-catalog Color Set palette applied via a tiny `Color` extension plus a root `.tint`; Liquid Glass chrome adapts automatically.

**Tech Stack:** Swift 6, SwiftUI (iOS 26), XcodeGen, Swift Testing.

**Spec:** `docs/superpowers/specs/2026-05-30-native-ios-app-design.md`

> **Inherited conventions (from Plan 1):**
> - Tests are **Swift Testing** (`@Suite`/`@Test`/`#expect`/`#require`), run via `cd ios/ConstitutionKit && swift test`.
> - `Section` clashes with `SwiftUI.Section`; in app files that `import SwiftUI`, write `ConstitutionKit.Section` for the model.
> - `ContentStore` is immutable, passed down explicitly as `let store: ContentStore`.
> - Build/run: `cd ios && xcodegen generate && xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO`. Screenshot: install/launch on the booted iPhone 17 Pro, then `xcrun simctl io booted screenshot <path>`.
> - Model fields available: `Case{id,name,shortName?,year,court,citation,principle,outcome,content,relatedSections,relatedCases,sourceUrl?}`, `Referendum{id,year,date?,title,question,outcome,yesPercentage,statesFor?,statesAgainst?,content,relatedSections}`, `HistoricalDocument{id,title,year,description,content,relatedSections,sourceUrl?}`. All models are `Identifiable & Hashable`. `Section.number` is a `String` ("0" = Preamble).

---

## Roadmap position

Plan 1 (done): foundation + Constitution flow. **Plan 2 (this doc).** Plan 3: global search. Plan 4: Saved + share. Plan 5: accessibility + Spotlight + widget + App Store prep.

## File Structure (Plan 2)

```
ios/ConstitutionApp/
├── Navigation/ContentDestinations.swift     # NEW: shared navigationDestinations modifier
├── Components/RelatedSection.swift           # NEW: generic titled list of navigation links
├── Theme/Palette.swift                       # NEW: Color extension over the asset catalog
├── Assets.xcassets/                          # NEW: parchment Color Sets (light + dark)
├── Cases/CaseListView.swift                  # NEW
├── Cases/CaseDetailView.swift                # NEW
├── Referendums/ReferendumListView.swift      # NEW
├── Referendums/ReferendumDetailView.swift    # NEW
├── Documents/DocumentListView.swift          # NEW
├── Documents/DocumentDetailView.swift        # NEW
├── RootTabView.swift                         # MODIFY: real tabs, shared destinations
├── ConstitutionApp.swift                     # MODIFY: apply .tint
├── Constitution/ChapterListView.swift        # MODIFY: pluralisation + shared destinations + bg
├── Constitution/SectionListView.swift        # MODIFY: background
└── Constitution/SectionDetailView.swift      # MODIFY: related items become navigable links
```

ConstitutionKit gains one tested helper (`sections(forReferences:)`).

> **Verification note:** Plan 2 is mostly SwiftUI views and an asset catalog, which are not unit-testable headlessly. Task 1 is real TDD (`swift test`). Tasks 2–9 are verified by `** BUILD SUCCEEDED **` plus screenshots that the controller inspects. Exact colour/spacing tuning happens in the screenshot-review loop, not by guessing.

---

## Task 1: ContentStore.sections(forReferences:) — dedup sub-paragraph refs

A case like `intergovernmental-immunities` lists `relatedSections: ["51(ii)", "51(vi)"]`; both resolve to `s51`. Detail screens must show **s51 once**. This helper resolves references (via the existing `section(reference:)`) and de-duplicates while preserving order.

**Files:**
- Modify: `ios/ConstitutionKit/Sources/ConstitutionKit/ContentStore.swift`
- Modify: `ios/ConstitutionKit/Tests/ConstitutionKitTests/ContentStoreTests.swift`

- [ ] **Step 1: Write the failing test** — append inside `ContentStoreTests`:

```swift
    @Test func sectionsForReferencesDedupsAndPreservesOrder() throws {
        let store = try makeStore()
        // "51(ii)" and "51(vi)" both resolve to s51 -> appear once; order preserved.
        let result = store.sections(forReferences: ["75(v)", "51(ii)", "51(vi)"])
        #expect(result.map(\.id) == ["s75", "s51"])
        // Unresolvable refs are dropped.
        #expect(store.sections(forReferences: ["nope", "51"]).map(\.id) == ["s51"])
        #expect(store.sections(forReferences: []).isEmpty)
    }
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd ios/ConstitutionKit && swift test --filter sectionsForReferencesDedupsAndPreservesOrder`
Expected: FAIL — `value of type 'ContentStore' has no member 'sections(forReferences:)'`.

- [ ] **Step 3: Implement** — add this method to `ContentStore`, in the `// MARK: Relations` section (right after `sections(for chapter:)`):

```swift
    /// Resolves section references (possibly sub-paragraph citations like
    /// "51(ii)") to sections, dropping unresolvable ones and de-duplicating
    /// while preserving first-seen order.
    public func sections(forReferences refs: [String]) -> [Section] {
        var seen = Set<String>()
        var result: [Section] = []
        for ref in refs {
            guard let section = section(reference: ref), seen.insert(section.id).inserted else { continue }
            result.append(section)
        }
        return result
    }
```

- [ ] **Step 4: Run the full suite**

Run: `cd ios/ConstitutionKit && swift test`
Expected: all tests pass (9 total now).

- [ ] **Step 5: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionKit
git commit -m "feat(ios): add ContentStore.sections(forReferences:) with dedup"
```

---

## Task 2: Shared navigation destinations + RelatedSection component

These two small pieces are used by every screen, so build them first.

**Files:**
- Create: `ios/ConstitutionApp/Navigation/ContentDestinations.swift`
- Create: `ios/ConstitutionApp/Components/RelatedSection.swift`

- [ ] **Step 1: Create the destinations modifier**

`ios/ConstitutionApp/Navigation/ContentDestinations.swift`:

```swift
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
```

(Note: `CaseDetailView`'s parameter is named `legalCase` because `case` is a Swift keyword.)

- [ ] **Step 2: Create the generic related-items section**

`ios/ConstitutionApp/Components/RelatedSection.swift`:

```swift
import SwiftUI

/// A titled block of navigation links to related content. Renders nothing when
/// `items` is empty. `Item` must be Hashable (for the link value) and
/// Identifiable (for ForEach); a destination must be registered via
/// `.contentDestinations(store:)` on the enclosing stack.
struct RelatedSection<Item: Identifiable & Hashable>: View {
    let title: String
    let items: [Item]
    let label: (Item) -> String

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        HStack {
                            Text(label(item))
                                .font(.callout)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
    }
}
```

- [ ] **Step 3: Verify it compiles** — this task can't build standalone (it references views created in Tasks 3–5). Do NOT build yet; just confirm the files are syntactically complete and commit.

- [ ] **Step 4: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Navigation ios/ConstitutionApp/Components
git commit -m "feat(ios): add shared navigation destinations and RelatedSection component"
```

---

## Task 3: Cases list + detail

**Files:**
- Create: `ios/ConstitutionApp/Cases/CaseListView.swift`
- Create: `ios/ConstitutionApp/Cases/CaseDetailView.swift`

- [ ] **Step 1: Case list**

`ios/ConstitutionApp/Cases/CaseListView.swift`:

```swift
import SwiftUI
import ConstitutionKit

struct CaseListView: View {
    let store: ContentStore

    private var cases: [Case] {
        store.cases.sorted { $0.year < $1.year }
    }

    var body: some View {
        NavigationStack {
            List(cases) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.shortName ?? item.name)
                            .font(.headline)
                        Text("\(item.citation) · \(String(item.year))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Cases")
            .contentDestinations(store: store)
        }
    }
}
```

- [ ] **Step 2: Case detail**

`ios/ConstitutionApp/Cases/CaseDetailView.swift`:

```swift
import SwiftUI
import ConstitutionKit

struct CaseDetailView: View {
    let store: ContentStore
    let legalCase: Case

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(legalCase.name)
                        .font(.system(.title, design: .serif))
                    Text("\(legalCase.court) · \(String(legalCase.year))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(legalCase.citation)
                        .font(.subheadline.monospaced())
                        .foregroundStyle(.secondary)
                }

                labelled("Principle", legalCase.principle)
                labelled("Outcome", legalCase.outcome.capitalized)

                Text(legalCase.content)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Sections",
                               items: store.sections(forReferences: legalCase.relatedSections)) {
                    $0.number == "0" ? "Preamble" : "Section \($0.number)"
                }
                RelatedSection(title: "Related Cases",
                               items: legalCase.relatedCases.compactMap { store.case(id: $0) }) {
                    $0.shortName ?? $0.name
                }

                if let urlString = legalCase.sourceUrl, let url = URL(string: urlString) {
                    Link("View on AustLII", destination: url)
                        .font(.callout)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(legalCase.shortName ?? legalCase.name)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    @ViewBuilder
    private func labelled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
```

- [ ] **Step 3: Build** (now buildable: RootTabView still references the Cases placeholder, which is fine — these new views aren't wired yet but must compile)

Run the standard build command (see header). Expected: `** BUILD SUCCEEDED **`. If `case` keyword or `Section` ambiguity errors appear, the parameter is named `legalCase` and the model is `ConstitutionKit.Section` — fix accordingly.

- [ ] **Step 4: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Cases
git commit -m "feat(ios): add Cases list and detail screens"
```

---

## Task 4: Referendums list + detail

**Files:**
- Create: `ios/ConstitutionApp/Referendums/ReferendumListView.swift`
- Create: `ios/ConstitutionApp/Referendums/ReferendumDetailView.swift`

- [ ] **Step 1: Referendum list**

`ios/ConstitutionApp/Referendums/ReferendumListView.swift`:

```swift
import SwiftUI
import ConstitutionKit

struct ReferendumListView: View {
    let store: ContentStore

    private var referendums: [Referendum] {
        store.referendums.sorted { $0.year < $1.year }
    }

    var body: some View {
        NavigationStack {
            List(referendums) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        HStack(spacing: 6) {
                            Text(String(item.year))
                            Text("·")
                            Text(item.outcome.capitalized)
                            Text("·")
                            Text("\(item.yesPercentage, specifier: "%.1f")% Yes")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Referendums")
            .contentDestinations(store: store)
        }
    }
}
```

- [ ] **Step 2: Referendum detail**

`ios/ConstitutionApp/Referendums/ReferendumDetailView.swift`:

```swift
import SwiftUI
import ConstitutionKit

struct ReferendumDetailView: View {
    let store: ContentStore
    let referendum: Referendum

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(referendum.title)
                        .font(.system(.title, design: .serif))
                    Text(referendum.date ?? String(referendum.year))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                labelled("Question", referendum.question)
                labelled("Outcome", referendum.outcome.capitalized)
                labelled("Yes vote", String(format: "%.2f%%", referendum.yesPercentage))
                if let f = referendum.statesFor, let a = referendum.statesAgainst {
                    labelled("States", "\(f) for · \(a) against")
                }

                Text(referendum.content)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Sections",
                               items: store.sections(forReferences: referendum.relatedSections)) {
                    $0.number == "0" ? "Preamble" : "Section \($0.number)"
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(String(referendum.year))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    @ViewBuilder
    private func labelled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
```

- [ ] **Step 3: Build** — standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Referendums
git commit -m "feat(ios): add Referendums list and detail screens"
```

---

## Task 5: Documents list + detail

**Files:**
- Create: `ios/ConstitutionApp/Documents/DocumentListView.swift`
- Create: `ios/ConstitutionApp/Documents/DocumentDetailView.swift`

- [ ] **Step 1: Document list**

`ios/ConstitutionApp/Documents/DocumentListView.swift`:

```swift
import SwiftUI
import ConstitutionKit

struct DocumentListView: View {
    let store: ContentStore

    private var documents: [HistoricalDocument] {
        store.documents.sorted { $0.year < $1.year }
    }

    var body: some View {
        NavigationStack {
            List(documents) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text(String(item.year))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Documents")
            .contentDestinations(store: store)
        }
    }
}
```

- [ ] **Step 2: Document detail**

`ios/ConstitutionApp/Documents/DocumentDetailView.swift`:

```swift
import SwiftUI
import ConstitutionKit

struct DocumentDetailView: View {
    let store: ContentStore
    let document: HistoricalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(document.title)
                        .font(.system(.title, design: .serif))
                    Text(String(document.year))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(document.description)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text(document.content)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Sections",
                               items: store.sections(forReferences: document.relatedSections)) {
                    $0.number == "0" ? "Preamble" : "Section \($0.number)"
                }

                if let urlString = document.sourceUrl, let url = URL(string: urlString) {
                    Link("View source", destination: url)
                        .font(.callout)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
```

- [ ] **Step 3: Build** — standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Documents
git commit -m "feat(ios): add Documents list and detail screens"
```

---

## Task 6: Wire the three tabs + shared destinations on Constitution

**Files:**
- Modify: `ios/ConstitutionApp/RootTabView.swift`
- Modify: `ios/ConstitutionApp/Constitution/ChapterListView.swift`

- [ ] **Step 1: Replace the placeholders in `RootTabView.swift`** with the real list views (Search stays a placeholder until Plan 3). Full new file:

```swift
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
                CaseListView(store: store)
            }
            Tab("Referendums", systemImage: "checkmark.seal") {
                ReferendumListView(store: store)
            }
            Tab("Documents", systemImage: "doc.text") {
                DocumentListView(store: store)
            }
            Tab(role: .search) {
                PlaceholderView(title: "Search", systemImage: "magnifyingglass")
            }
        }
    }
}
```

- [ ] **Step 2: Update `ChapterListView.swift`** to use the shared destinations (so sections can link onward to cases/referendums/documents) and fix the "1 sections" pluralisation. Full new file:

```swift
import SwiftUI
import ConstitutionKit

struct ChapterListView: View {
    let store: ContentStore

    var body: some View {
        NavigationStack {
            List(store.chapters) { chapter in
                let count = store.sections(for: chapter).count
                NavigationLink(value: chapter) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chapter.title)
                            .font(.headline)
                        Text(count == 1 ? "1 section" : "\(count) sections")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Constitution")
            .contentDestinations(store: store)
        }
    }
}
```

- [ ] **Step 3: Build, launch, screenshot each tab**

Run the standard build command. Expected: `** BUILD SUCCEEDED **`. Then:
```bash
APP=$(find ~/Library/Developer/Xcode/DerivedData -type d -name "ConstitutionApp.app" -path "*Debug-iphonesimulator*" 2>/dev/null | head -1)
xcrun simctl install booted "$APP"
xcrun simctl launch booted au.constitution.app
sleep 3
xcrun simctl io booted screenshot /tmp/p2-cases.png
```
Manually tap into Cases/Referendums/Documents in the simulator if possible; at minimum capture `/tmp/p2-cases.png` after launching. Report screenshot paths for the controller to inspect.

- [ ] **Step 4: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/RootTabView.swift ios/ConstitutionApp/Constitution/ChapterListView.swift
git commit -m "feat(ios): wire Cases/Referendums/Documents tabs; fix section pluralisation"
```

---

## Task 7: Make Constitution section detail's related items navigable

**Files:**
- Modify: `ios/ConstitutionApp/Constitution/SectionDetailView.swift`

- [ ] **Step 1: Replace `SectionDetailView.swift`** so related items use the navigable `RelatedSection` component instead of plain text. Full new file:

```swift
import SwiftUI
import ConstitutionKit

struct SectionDetailView: View {
    let store: ContentStore
    let section: ConstitutionKit.Section

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(section.title)
                    .font(.system(.title, design: .serif))

                Text(section.content)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(6)
                    .textSelection(.enabled)

                RelatedSection(title: "Related Cases",
                               items: store.cases(for: section)) {
                    $0.shortName ?? $0.name
                }
                RelatedSection(title: "Related Referendums",
                               items: store.referendums(for: section)) {
                    "\($0.title) (\(String($0.year)))"
                }
                RelatedSection(title: "Related Documents",
                               items: store.documents(for: section)) {
                    $0.title
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(section.number == "0" ? "Preamble" : "Section \(section.number)")
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
```

(The private `relatedSection` helper is removed — `RelatedSection` replaces it.)

- [ ] **Step 2: Build, launch, screenshot a section with related items**

Run the standard build command. Expected: `** BUILD SUCCEEDED **`. Launch, navigate Constitution → The Parliament → Section 51, and capture:
```bash
xcrun simctl io booted screenshot /tmp/p2-section51.png
```
Verify related cases appear as tappable rows. Report the path.

- [ ] **Step 3: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Constitution/SectionDetailView.swift
git commit -m "feat(ios): make section detail related items navigable"
```

---

## Task 8: Parchment palette — Color Sets + tint

**Files:**
- Create: `ios/ConstitutionApp/Assets.xcassets/Contents.json`
- Create: 7 color sets under `ios/ConstitutionApp/Assets.xcassets/` (each a folder with `Contents.json`)
- Create: `ios/ConstitutionApp/Theme/Palette.swift`
- Modify: `ios/ConstitutionApp/ConstitutionApp.swift`

- [ ] **Step 1: Create the asset catalog root** — `ios/ConstitutionApp/Assets.xcassets/Contents.json`:

```json
{
  "info" : { "author" : "xcode", "version" : 1 }
}
```

- [ ] **Step 2: Create the 7 color sets.** For each colour below, create `ios/ConstitutionApp/Assets.xcassets/<Name>.colorset/Contents.json` using this exact template, substituting the light and dark hex components:

Template (replace `LR/LG/LB` light hex bytes and `DR/DG/DB` dark hex bytes):
```json
{
  "colors" : [
    {
      "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0xLR", "green" : "0xLG", "blue" : "0xLB" } },
      "idiom" : "universal"
    },
    {
      "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ],
      "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0xDR", "green" : "0xDG", "blue" : "0xDB" } },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

The 7 colour sets (light → dark):

| Name | Light hex | Dark hex |
|------|-----------|----------|
| `AppBackground` | `F5 F0 E8` | `1C 18 14` |
| `AppSurface` | `ED E7 DB` | `26 21 1B` |
| `TextPrimary` | `3D 32 29` | `ED E7 DB` |
| `TextSecondary` | `6B 5D 4F` | `B8 A9 98` |
| `AccentGreen` | `2E 5A 4A` | `6F B8 9C` |
| `AccentGold` | `B8 93 5A` | `D4 B4 83` |
| `AccentBurgundy` | `8B 2E 2E` | `CE 7B 7B` |

Example — `ios/ConstitutionApp/Assets.xcassets/AppBackground.colorset/Contents.json`:
```json
{
  "colors" : [
    {
      "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0xF5", "green" : "0xF0", "blue" : "0xE8" } },
      "idiom" : "universal"
    },
    {
      "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ],
      "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0x1C", "green" : "0x18", "blue" : "0x14" } },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```
Create the remaining six the same way with their hex values from the table.

- [ ] **Step 3: Create the Color extension** — `ios/ConstitutionApp/Theme/Palette.swift`:

```swift
import SwiftUI

extension Color {
    static let appBackground = Color("AppBackground")
    static let appSurface = Color("AppSurface")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let accentGreen = Color("AccentGreen")
    static let accentGold = Color("AccentGold")
    static let accentBurgundy = Color("AccentBurgundy")
}
```

- [ ] **Step 4: Apply the accent tint app-wide** — replace `ios/ConstitutionApp/ConstitutionApp.swift`:

```swift
import SwiftUI
import ConstitutionKit

@main
struct ConstitutionApp: App {
    let store = ContentStore.bundled()

    var body: some Scene {
        WindowGroup {
            RootTabView(store: store)
                .tint(.accentGreen)
        }
    }
}
```

- [ ] **Step 5: Build, launch, screenshot (light mode)**

Run the standard build command. Expected: `** BUILD SUCCEEDED **`. Confirm the asset catalog compiled (no "unknown color" runtime warnings). Launch and capture:
```bash
xcrun simctl io booted screenshot /tmp/p2-tinted-light.png
```
Report the path. (Tinting should turn nav/links/selected tab green.)

- [ ] **Step 6: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Assets.xcassets ios/ConstitutionApp/Theme ios/ConstitutionApp/ConstitutionApp.swift
git commit -m "feat(ios): add parchment Color Sets and apply accent tint"
```

---

## Task 9: Apply backgrounds + reading colour; verify light & dark

Apply the parchment background to lists and reading views and the warm text colour to body copy, then verify both appearances. Keep changes minimal — Liquid Glass chrome is left to adapt on its own.

**Files:**
- Modify: `ios/ConstitutionApp/Constitution/ChapterListView.swift`
- Modify: `ios/ConstitutionApp/Cases/CaseListView.swift`
- Modify: `ios/ConstitutionApp/Referendums/ReferendumListView.swift`
- Modify: `ios/ConstitutionApp/Documents/DocumentListView.swift`
- Modify: `ios/ConstitutionApp/Constitution/SectionDetailView.swift`
- Modify: `ios/ConstitutionApp/Cases/CaseDetailView.swift`
- Modify: `ios/ConstitutionApp/Referendums/ReferendumDetailView.swift`
- Modify: `ios/ConstitutionApp/Documents/DocumentDetailView.swift`

- [ ] **Step 1: Apply parchment background to each List.** In all four list views, add these two modifiers to the `List` (immediately after the existing `.contentDestinations(store: store)` line on the List, i.e. chained on the List, not the NavigationStack):

```swift
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
```

For example, `ChapterListView`'s List becomes:
```swift
            List(store.chapters) { chapter in
                // ... unchanged row ...
            }
            .navigationTitle("Constitution")
            .contentDestinations(store: store)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
```
Apply the same two lines to `CaseListView`, `ReferendumListView`, and `DocumentListView` (they have `.navigationTitle(...)` then `.contentDestinations(store: store)`; add the two background lines after).

- [ ] **Step 2: Apply background + reading colour to each detail `ScrollView`.** In all four detail views, add to the `ScrollView`:
   - set body text colour: change the main content `Text(...).font(.system(.body, design: .serif))` to also have `.foregroundStyle(Color.textPrimary)`,
   - add `.background(Color.appBackground)` to the `ScrollView` (after `.frame(maxWidth:...)`'s parent, i.e. as a modifier on the ScrollView itself, before `.navigationTitle`).

Concretely, in each detail view the ScrollView modifier chain becomes:
```swift
        }
        .background(Color.appBackground)
        .navigationTitle(/* unchanged */)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
```
and the primary body `Text` gains `.foregroundStyle(Color.textPrimary)`. Apply to `SectionDetailView`, `CaseDetailView`, `ReferendumDetailView`, `DocumentDetailView`.

- [ ] **Step 3: Build, launch, screenshot LIGHT mode**

Run the standard build command. Expected: `** BUILD SUCCEEDED **`. Launch, then:
```bash
xcrun simctl ui booted appearance light
xcrun simctl io booted screenshot /tmp/p2-final-light.png
```

- [ ] **Step 4: Screenshot DARK mode**

```bash
xcrun simctl ui booted appearance dark
sleep 1
xcrun simctl io booted screenshot /tmp/p2-final-dark.png
xcrun simctl ui booted appearance light
```
Report both paths. The controller will inspect that: light shows the warm parchment background; dark shows the warm-dark background with light text and lightened accents; the tab bar (Liquid Glass) is legible in both.

- [ ] **Step 5: Commit**

```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp
git commit -m "feat(ios): apply parchment backgrounds and reading colour; verify light/dark"
```

---

## Self-Review (completed during authoring)

- **Spec coverage (Plan 2 scope):** Cases/Referendums/Documents tabs with detail screens (Tasks 3–6) ✓; light + dark theming via Color Sets (Tasks 8–9) ✓; serif reading retained + warm text/background ✓; related items navigable across all types via shared destinations + `RelatedSection` (Tasks 2, 7, and each detail) ✓; `.tabBarMinimizeBehavior` on every reading screen ✓; Liquid Glass left to adapt (no custom chrome) per the HIG rule ✓; pluralisation polish carried over from Plan 1 (Task 6) ✓. Global search, Saved, share, accessibility, Spotlight, widget remain in Plans 3–5.
- **Placeholder scan:** No "TBD"/vague steps; every code step is complete. The Search `PlaceholderView` is an intentional, scoped stub (Plan 3). Task 2's "don't build yet" is explained (it depends on Task 3–5 views) rather than a hidden gap.
- **Type consistency:** `CaseDetailView(store:legalCase:)`, `ReferendumDetailView(store:referendum:)`, `DocumentDetailView(store:document:)` parameter labels match between `ContentDestinations.swift` (Task 2) and the view definitions (Tasks 3–5). `RelatedSection(title:items:label:)` signature matches all call sites. `store.sections(forReferences:)` (Task 1) is used in Tasks 3–5. `Color.appBackground`/`.textPrimary`/`.accentGreen` (Task 8) match the asset-set names (the 7-row table) and their uses in Tasks 8–9. `ConstitutionKit.Section` disambiguation preserved.
- **Verification honesty:** Task 1 is real `swift test` TDD; UI tasks are gated on `** BUILD SUCCEEDED **` plus controller-inspected screenshots (light and dark), since SwiftUI views and asset catalogs aren't headlessly unit-testable.
