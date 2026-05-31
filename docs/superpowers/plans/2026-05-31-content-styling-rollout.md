# Content Styling Rollout — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the (now-validated) design-system components to all remaining content screens — Cases, Documents, Constitution chapters/sections, and the detail screens — and reduce the tab-bar label size.

**Architecture:** Reuse the proven `DesignSystem/` components (`ContentCard`, `ScreenHeader`, `YearBadge`, `OutcomeBadge`, `FilterPills`, `FlowLayout`, `SectionRefPill`, `AppFont`, palette) exactly as the Referendums screens do. Two new small components (`AmendmentNote`, `RelatedItemsSection`) support the section reading view. Native `NavigationStack` + Liquid Glass tab bar unchanged except a smaller tab label font.

**Tech Stack:** Swift 6, SwiftUI (iOS 26), XcodeGen.

**Spec:** `docs/superpowers/specs/2026-05-31-content-styling-design-system.md`. **Reference exemplar:** `ios/ConstitutionApp/Referendums/ReferendumListView.swift` + `ReferendumDetailView.swift` (the approved look).

> **Inherited conventions:** build/run + screenshot as before (`xcodegen generate`; `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 17 Pro' ... CODE_SIGNING_ALLOWED=NO`). `Section` → `ConstitutionKit.Section` in app files. Existing components/APIs: `ContentCard(accent:content:)`, `ScreenHeader(title:subtitle:)`, `YearBadge(text:)`, `OutcomeBadge(text:foreground:background:)`, `FilterPills(options:selection:)` w/ `Option(title:value:activeColor:)`, `SectionRefPill(reference:store:)`, `FlowLayout(spacing:)`, `AppFont.*`, `Color.{appBackground,appSurface,textPrimary,textSecondary,accentGreen,accentGold,accentBurgundy,tintGreen,tintGold,tintBurgundy,cardBorder}`. Nav: `.contentDestinations(store:)`. Store: `chapters`, `sections(for:)`, `cases`, `documents`, `case(id:)`, `cases(for:)`, `referendums(for:)`, `documents(for:)`, `sections(forReferences:)`, `section(reference:)`. Models: `Case{id,name,shortName?,year,court,citation,principle,outcome,content,relatedSections,relatedCases,sourceUrl?}`, `HistoricalDocument{id,title,year,description,content,relatedSections,sourceUrl?}`, `Chapter{number,title,slug,sectionIDs,id}`, `ConstitutionKit.Section{id,number(String),title,content,notes?,relatedCases,relatedReferendums,relatedDocuments}`.

> **Verification:** pure SwiftUI — no headless tests. Each task gated on `** BUILD SUCCEEDED **`. The controller does light+dark screenshots for representative screens (Cases list, section reading view) by temporarily rooting the app at that view (as done for Referendums), then reverting. `swift test` (9 tests) must remain green at the end.

---

## Task 1: Reduce tab-bar label size (preserve Liquid Glass)

**Files:** Modify `ios/ConstitutionApp/ConstitutionApp.swift`

- [ ] **Step 1: Add a tab-bar appearance that only shrinks the title font** (leave the background untouched so Liquid Glass is preserved). Replace the file:

```swift
import SwiftUI
import ConstitutionKit
import UIKit

@main
struct ConstitutionApp: App {
    let store = ContentStore.bundled()

    init() {
        // Shrink only the tab-bar label font; do NOT reconfigure the background,
        // so the iOS 26 Liquid Glass material is preserved.
        let smaller = UIFont.systemFont(ofSize: 10, weight: .medium)
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
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(store: store)
                .tint(.accentGreen)
        }
    }
}
```

(Reading the existing `standardAppearance` and mutating only `titleTextAttributes` avoids replacing the glass background. We do not touch icon rendering — SF Symbol tab icons are system-sized under Liquid Glass.)

- [ ] **Step 2: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: CONTROLLER verification (not subagent).** Launch and screenshot the tab bar; confirm (a) labels are smaller, (b) the Liquid Glass material and separated search tab are intact. **If the glass is degraded or the change has no visible effect**, STOP and report DONE_WITH_CONCERNS describing what happened — the controller will decide whether to keep, adjust the size, or revert (the tweak must not cost the glass look).

- [ ] **Step 4: Commit:**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/ConstitutionApp.swift
git commit -m "feat(ios): reduce tab-bar label font size"
```

---

## Task 2: Support components — AmendmentNote + RelatedItemsSection

**Files:**
- Create: `ios/ConstitutionApp/DesignSystem/AmendmentNote.swift`
- Create: `ios/ConstitutionApp/DesignSystem/RelatedItemsSection.swift`

- [ ] **Step 1: `AmendmentNote.swift`** (burgundy note box for a section's `notes`):
```swift
import SwiftUI

/// Burgundy-tinted note box with a leading stripe, for a section's amendment note.
struct AmendmentNote: View {
    let text: String
    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(Color.accentBurgundy).frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text("NOTE")
                    .font(AppFont.badge)
                    .tracking(0.5)
                    .foregroundStyle(Color.accentBurgundy)
                Text(text)
                    .font(AppFont.body)
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.tintBurgundy)
        .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 6, topTrailingRadius: 6))
    }
}
```

- [ ] **Step 2: `RelatedItemsSection.swift`** (a titled group of related-content cards that navigate):
```swift
import SwiftUI

/// A titled section of related-content cards. Each card navigates to its item
/// (a destination must be registered via `.contentDestinations(store:)`).
/// Renders nothing when `items` is empty.
struct RelatedItemsSection<Item: Identifiable & Hashable>: View {
    let title: String
    let items: [Item]
    var accent: Color = .accentGreen
    let primary: (Item) -> String
    var secondary: (Item) -> String? = { _ in nil }

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title.uppercased())
                    .font(AppFont.badge)
                    .tracking(0.5)
                    .foregroundStyle(Color.textSecondary)
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        ContentCard(accent: accent) {
                            Text(primary(item))
                                .font(AppFont.cardTitle)
                                .foregroundStyle(Color.textPrimary)
                            if let sub = secondary(item) {
                                Text(sub)
                                    .font(AppFont.body)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
```

- [ ] **Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit:**
```bash
git add ios/ConstitutionApp/DesignSystem/AmendmentNote.swift ios/ConstitutionApp/DesignSystem/RelatedItemsSection.swift
git commit -m "feat(ios): add AmendmentNote and RelatedItemsSection components"
```

---

## Task 3: Restyle Cases (list + detail)

**Files:** full-replace `ios/ConstitutionApp/Cases/CaseListView.swift` and `ios/ConstitutionApp/Cases/CaseDetailView.swift`

- [ ] **Step 1: `CaseListView.swift`:**
```swift
import SwiftUI
import ConstitutionKit

struct CaseListView: View {
    let store: ContentStore

    enum Sort: Hashable { case year, name }
    @State private var sort: Sort = .year

    private var cases: [Case] {
        switch sort {
        case .year: return store.cases.sorted { $0.year < $1.year }
        case .name: return store.cases.sorted { ($0.shortName ?? $0.name) < ($1.shortName ?? $1.name) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Cases", subtitle: "\(store.cases.count) landmark cases")
                    FilterPills(options: [
                        .init(title: "By year", value: .year, activeColor: .accentGreen),
                        .init(title: "By name", value: .name, activeColor: .accentGreen),
                    ], selection: $sort)
                    LazyVStack(spacing: 10) {
                        ForEach(cases) { item in
                            NavigationLink(value: item) {
                                CaseCard(legalCase: item, store: store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .navigationTitle("Cases")
            .navigationBarTitleDisplayMode(.inline)
            .contentDestinations(store: store)
        }
    }
}

private struct CaseCard: View {
    let legalCase: Case
    let store: ContentStore
    private var dissent: Bool { legalCase.outcome.lowercased() == "dissent" }

    var body: some View {
        ContentCard(accent: dissent ? .accentBurgundy : .accentGreen) {
            HStack(alignment: .top) {
                YearBadge(text: String(legalCase.year))
                Spacer()
                if !legalCase.relatedSections.isEmpty {
                    FlowLayout(spacing: 4) {
                        ForEach(legalCase.relatedSections.prefix(4), id: \.self) { ref in
                            SectionRefPill(reference: ref, store: store)
                        }
                    }
                    .frame(maxWidth: 160, alignment: .trailing)
                }
            }
            Text(legalCase.name)
                .font(AppFont.cardTitle)
                .foregroundStyle(Color.textPrimary)
            Text(legalCase.principle)
                .font(AppFont.body)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(3)
            Text(legalCase.court)
                .font(AppFont.monoSmall)
                .foregroundStyle(Color.textSecondary)
        }
    }
}
```

- [ ] **Step 2: `CaseDetailView.swift`:**
```swift
import SwiftUI
import ConstitutionKit

struct CaseDetailView: View {
    let store: ContentStore
    let legalCase: Case

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    YearBadge(text: String(legalCase.year))
                    Text(legalCase.name)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                    Text("\(legalCase.court) · \(legalCase.citation)")
                        .font(AppFont.monoSmall)
                        .foregroundStyle(Color.textSecondary)
                }

                labelled("Principle", legalCase.principle)
                labelled("Outcome", legalCase.outcome.capitalized)

                Text(legalCase.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                let sections = store.sections(forReferences: legalCase.relatedSections)
                if !sections.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RELATED SECTIONS").font(AppFont.badge).tracking(0.5)
                            .foregroundStyle(Color.textSecondary)
                        FlowLayout(spacing: 4) {
                            ForEach(legalCase.relatedSections, id: \.self) { ref in
                                SectionRefPill(reference: ref, store: store)
                            }
                        }
                    }
                }

                RelatedItemsSection(
                    title: "Related Cases",
                    items: legalCase.relatedCases.compactMap { store.case(id: $0) },
                    accent: .accentGreen,
                    primary: { $0.shortName ?? $0.name },
                    secondary: { String($0.year) }
                )

                if let urlString = legalCase.sourceUrl, let url = URL(string: urlString) {
                    Link("View on AustLII", destination: url).font(AppFont.body)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(legalCase.shortName ?? legalCase.name)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    @ViewBuilder
    private func labelled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline).foregroundStyle(Color.textPrimary)
            Text(value).font(AppFont.body).foregroundStyle(Color.textSecondary)
        }
    }
}
```

- [ ] **Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit:**
```bash
git add ios/ConstitutionApp/Cases
git commit -m "feat(ios): restyle Cases list and detail with design system"
```

---

## Task 4: Restyle Documents (list + detail)

**Files:** full-replace `ios/ConstitutionApp/Documents/DocumentListView.swift` and `ios/ConstitutionApp/Documents/DocumentDetailView.swift`

- [ ] **Step 1: `DocumentListView.swift`:**
```swift
import SwiftUI
import ConstitutionKit

struct DocumentListView: View {
    let store: ContentStore
    private var documents: [HistoricalDocument] { store.documents.sorted { $0.year < $1.year } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Documents", subtitle: "\(store.documents.count) foundational documents")
                    LazyVStack(spacing: 10) {
                        ForEach(documents) { item in
                            NavigationLink(value: item) {
                                ContentCard(accent: .accentGold) {
                                    YearBadge(text: String(item.year))
                                    Text(item.title)
                                        .font(AppFont.cardTitle)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(item.description)
                                        .font(AppFont.body)
                                        .foregroundStyle(Color.textSecondary)
                                        .lineLimit(3)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .navigationTitle("Documents")
            .navigationBarTitleDisplayMode(.inline)
            .contentDestinations(store: store)
        }
    }
}
```

- [ ] **Step 2: `DocumentDetailView.swift`:**
```swift
import SwiftUI
import ConstitutionKit

struct DocumentDetailView: View {
    let store: ContentStore
    let document: HistoricalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    YearBadge(text: String(document.year))
                    Text(document.title)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                }
                Text(document.description)
                    .font(AppFont.body)
                    .foregroundStyle(Color.textSecondary)

                Text(document.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                let sections = store.sections(forReferences: document.relatedSections)
                if !sections.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RELATED SECTIONS").font(AppFont.badge).tracking(0.5)
                            .foregroundStyle(Color.textSecondary)
                        FlowLayout(spacing: 4) {
                            ForEach(document.relatedSections, id: \.self) { ref in
                                SectionRefPill(reference: ref, store: store)
                            }
                        }
                    }
                }

                if let urlString = document.sourceUrl, let url = URL(string: urlString) {
                    Link("View source", destination: url).font(AppFont.body)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(String(document.year))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
```

- [ ] **Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit:**
```bash
git add ios/ConstitutionApp/Documents
git commit -m "feat(ios): restyle Documents list and detail with design system"
```

---

## Task 5: Restyle Constitution chapters + section list

**Files:** full-replace `ios/ConstitutionApp/Constitution/ChapterListView.swift` and `ios/ConstitutionApp/Constitution/SectionListView.swift`

- [ ] **Step 1: `ChapterListView.swift`:**
```swift
import SwiftUI
import ConstitutionKit

struct ChapterListView: View {
    let store: ContentStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Constitution",
                                 subtitle: "Commonwealth of Australia Constitution Act 1900")
                    LazyVStack(spacing: 10) {
                        ForEach(store.chapters) { chapter in
                            let count = store.sections(for: chapter).count
                            NavigationLink(value: chapter) {
                                ContentCard(accent: .accentGreen) {
                                    Text(chapter.title)
                                        .font(AppFont.cardTitle)
                                        .foregroundStyle(Color.textPrimary)
                                    Text(count == 1 ? "1 section" : "\(count) sections")
                                        .font(AppFont.monoSmall)
                                        .foregroundStyle(Color.textSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .navigationTitle("Constitution")
            .navigationBarTitleDisplayMode(.inline)
            .contentDestinations(store: store)
        }
    }
}
```

- [ ] **Step 2: `SectionListView.swift`:**
```swift
import SwiftUI
import ConstitutionKit

struct SectionListView: View {
    let store: ContentStore
    let chapter: Chapter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: chapter.title, subtitle: nil)
                LazyVStack(spacing: 10) {
                    ForEach(store.sections(for: chapter)) { section in
                        NavigationLink(value: section) {
                            ContentCard(accent: .accentGreen) {
                                Text(section.number == "0" ? "Preamble" : "Section \(section.number)")
                                    .font(AppFont.monoSmall)
                                    .foregroundStyle(Color.textSecondary)
                                Text(section.title)
                                    .font(AppFont.cardTitle)
                                    .foregroundStyle(Color.textPrimary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground)
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
```

- [ ] **Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit:**
```bash
git add ios/ConstitutionApp/Constitution/ChapterListView.swift ios/ConstitutionApp/Constitution/SectionListView.swift
git commit -m "feat(ios): restyle Constitution chapters and section list"
```

---

## Task 6: Restyle the section reading view

**Files:** full-replace `ios/ConstitutionApp/Constitution/SectionDetailView.swift`

- [ ] **Step 1: `SectionDetailView.swift`:**
```swift
import SwiftUI
import ConstitutionKit

struct SectionDetailView: View {
    let store: ContentStore
    let section: ConstitutionKit.Section

    private var label: String { section.number == "0" ? "Preamble" : "Section \(section.number)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(label.uppercased())
                        .font(AppFont.monoSmall)
                        .foregroundStyle(Color.textSecondary)
                    Text(section.title)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                }

                Text(section.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                if let notes = section.notes, !notes.isEmpty {
                    AmendmentNote(text: notes)
                }

                RelatedItemsSection(
                    title: "Related Cases",
                    items: store.cases(for: section),
                    accent: .accentGreen,
                    primary: { $0.shortName ?? $0.name },
                    secondary: { "\($0.court) · \(String($0.year))" }
                )
                RelatedItemsSection(
                    title: "Related Referendums",
                    items: store.referendums(for: section),
                    accent: .accentGold,
                    primary: { $0.title },
                    secondary: { "\(String($0.year)) · \($0.outcome.capitalized)" }
                )
                RelatedItemsSection(
                    title: "Related Documents",
                    items: store.documents(for: section),
                    accent: .accentGold,
                    primary: { $0.title },
                    secondary: { String($0.year) }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(label)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
```

- [ ] **Step 2: Build.** Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit:**
```bash
git add ios/ConstitutionApp/Constitution/SectionDetailView.swift
git commit -m "feat(ios): restyle section reading view with serif body, notes, related cards"
```

---

## Task 7: Remove orphaned component + final verification

**Files:** possibly delete `ios/ConstitutionApp/Components/RelatedSection.swift`

- [ ] **Step 1: Check whether `RelatedSection` is still referenced** (it was used by the old SectionDetailView, now replaced by `RelatedItemsSection`):
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
grep -rn "RelatedSection(" ios/ConstitutionApp --include=*.swift | grep -v "RelatedItemsSection"
```
If there are **no** matches (other than `RelatedItemsSection`), delete the orphaned file:
```bash
git rm ios/ConstitutionApp/Components/RelatedSection.swift
```
If it is still referenced anywhere, leave it and note where.

- [ ] **Step 2: Full build + unit suite green:**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate
xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios/ConstitutionKit && swift test
```
Expected: `** BUILD SUCCEEDED **` and 9 tests pass.

- [ ] **Step 3: Commit** (if the file was removed):
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git commit -m "chore(ios): remove orphaned RelatedSection component"
```

> **CONTROLLER verification:** after the build is green, screenshot (light + dark) the Cases list and the section reading view (via temporary-root, as done for Referendums) and confirm the styling matches the exemplar. Reinstall the proper tabbed app afterward.

---

## Self-Review (completed during authoring)

- **Spec coverage:** Cases list+detail (Task 3) ✓; Documents list+detail (Task 4) ✓; chapters + section list (Task 5) ✓; section reading view with serif body, `AmendmentNote`, related cards (Task 6) ✓; tab-bar label size reduction (Task 1) ✓; new support components `AmendmentNote`/`RelatedItemsSection` (Task 2) ✓; all reuse the validated components and keep native nav + Liquid Glass tab bar; `.tabBarMinimizeBehavior` on every reading screen ✓. Orphan cleanup (Task 7) ✓.
- **Placeholder scan:** none — every step has complete code/commands.
- **Type consistency:** `RelatedItemsSection(title:items:accent:primary:secondary:)`, `AmendmentNote(text:)`, `CaseListView.Sort`, `ContentCard`/`ScreenHeader`/`FilterPills`/`SectionRefPill`/`FlowLayout`/`YearBadge`/`AppFont`/palette usages match their definitions (Plan: design-system) and the model fields listed in the conventions block. `store.case(id:)`, `store.cases(for:)`, `store.sections(forReferences:)`, `store.sections(for:)` exist. `legalCase` param name (keyword avoidance) consistent with `ContentDestinations.swift`.
- **Risk flags:** (1) Task 1 tab-bar font override under Liquid Glass is uncertain — Step 3 mandates controller verification with a revert path if glass degrades. (2) `FlowLayout` in the trailing position of a `CaseCard` header is constrained to `maxWidth: 160`; if it looks cramped, the fallback is to move section pills to their own row below the principle (note for the screenshot review).
