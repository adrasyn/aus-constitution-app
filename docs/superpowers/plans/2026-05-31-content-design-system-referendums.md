# Content Design System + Referendums Exemplar — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the reusable SwiftUI design-system layer (parchment cards, badges, pills, serif headers) and restyle the **Referendums** list + detail screens with it — as the exemplar to validate the look before rolling out to the other content screens.

**Architecture:** A `DesignSystem/` folder of small single-purpose views driven by theme tokens (fonts + Color Sets). Content screens become `ScrollView { LazyVStack }` of `ContentCard`s inside the existing native `NavigationStack`s; Liquid Glass tab bar and nav chrome are untouched.

**Tech Stack:** Swift 6, SwiftUI (iOS 26), XcodeGen.

**Spec:** `docs/superpowers/specs/2026-05-31-content-styling-design-system.md`

> **Inherited conventions:** build/run + screenshot commands as in prior plans (`xcodegen generate`; `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 17 Pro' ... CODE_SIGNING_ALLOWED=NO`; `xcrun simctl io booted screenshot <path>`; dark via `xcrun simctl ui booted appearance dark`). `Section` → `ConstitutionKit.Section` in app files. The booted iPhone 17 Pro simulator is reused. `Color.appBackground/appSurface/textPrimary/textSecondary/accentGreen/accentGold/accentBurgundy` already exist (`Theme/Palette.swift`). `ContentStore.section(reference:)` resolves section refs.

---

## Scope of THIS plan

Design-system components + **Referendums** screens only. After Task 6, the controller screenshots light+dark and validates with the user. A **follow-up plan** then applies the same components to Cases, Documents, Chapters, Sections, and the detail screens (quick, since the components will be proven).

## File Structure

```
ios/ConstitutionApp/
├── Assets.xcassets/            # MODIFY: + TintGreen/TintGold/TintBurgundy/CardBorder colorsets
├── Theme/Palette.swift         # MODIFY: + tint/cardBorder Color accessors
├── DesignSystem/
│   ├── AppFont.swift           # NEW: serif/sans/mono font tokens
│   ├── ContentCard.swift       # NEW: parchment card w/ leading accent stripe
│   ├── ScreenHeader.swift      # NEW: serif H1 + sans subtitle
│   ├── Badges.swift            # NEW: YearBadge + OutcomeBadge
│   ├── FilterPills.swift       # NEW: generic pill segmented control
│   ├── FlowLayout.swift        # NEW: wrapping layout for pills
│   └── SectionRefPill.swift    # NEW: mono chip linking to a section
├── Referendums/ReferendumListView.swift    # MODIFY: ScrollView + cards + filters
└── Referendums/ReferendumDetailView.swift  # MODIFY: serif header + badges + related pills
```

> **Verification:** pure SwiftUI views + asset catalog — no headless unit tests. Each task is gated on `** BUILD SUCCEEDED **`; Task 6 adds controller-inspected light & dark screenshots. The existing `swift test` suite must remain green (run once at the end).

---

## Task 1: Color Sets + theme tokens

**Files:**
- Create 4 colorsets under `ios/ConstitutionApp/Assets.xcassets/`
- Modify: `ios/ConstitutionApp/Theme/Palette.swift`
- Create: `ios/ConstitutionApp/DesignSystem/AppFont.swift`

- [ ] **Step 1: Add 4 Color Sets.** For each, create `ios/ConstitutionApp/Assets.xcassets/<Name>.colorset/Contents.json` using the established template (universal light + a dark `luminosity` appearance, srgb `0xRR` byte components):

| Name | Light | Dark |
|------|-------|------|
| `TintGreen` | `E8 F0 EC` | `20 30 2A` |
| `TintGold` | `F5 EF E0` | `32 2B 1E` |
| `TintBurgundy` | `F3 EA EA` | `3A 24 24` |
| `CardBorder` | `D4 C9 B8` | `3A 33 2B` |

Example — `TintGreen.colorset/Contents.json`:
```json
{
  "colors" : [
    { "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0xE8", "green" : "0xF0", "blue" : "0xEC" } }, "idiom" : "universal" },
    { "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ], "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "red" : "0x20", "green" : "0x30", "blue" : "0x2A" } }, "idiom" : "universal" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```
Create the other three the same way with their hex values.

- [ ] **Step 2: Extend `Theme/Palette.swift`** — add to the existing `extension Color`:
```swift
    static let tintGreen = Color("TintGreen")
    static let tintGold = Color("TintGold")
    static let tintBurgundy = Color("TintBurgundy")
    static let cardBorder = Color("CardBorder")
```

- [ ] **Step 3: Create `ios/ConstitutionApp/DesignSystem/AppFont.swift`:**
```swift
import SwiftUI

/// Typography tokens mirroring the web app: Georgia serif for titles and
/// reading, the system sans for UI text, system monospaced for numerics.
/// All scale with Dynamic Type via `relativeTo:`.
enum AppFont {
    static let screenTitle = Font.custom("Georgia", size: 28, relativeTo: .largeTitle)
    static let cardTitle = Font.custom("Georgia", size: 17, relativeTo: .headline)
    static let readingTitle = Font.custom("Georgia", size: 24, relativeTo: .title)
    static let readingBody = Font.custom("Georgia", size: 17, relativeTo: .body)
    static let subtitle = Font.subheadline
    static let body = Font.subheadline
    static let badge = Font.system(.caption2, design: .default).weight(.semibold)
    static let mono = Font.system(.caption, design: .monospaced)
    static let monoSmall = Font.system(.caption2, design: .monospaced)
}
```

- [ ] **Step 4: Build.** Run the standard build command. Expected: `** BUILD SUCCEEDED **` (no asset warnings).

- [ ] **Step 5: Commit:**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Assets.xcassets ios/ConstitutionApp/Theme ios/ConstitutionApp/DesignSystem/AppFont.swift
git commit -m "feat(ios): add tint Color Sets and typography tokens"
```

---

## Task 2: ContentCard, ScreenHeader, Badges

**Files:**
- Create: `ios/ConstitutionApp/DesignSystem/ContentCard.swift`
- Create: `ios/ConstitutionApp/DesignSystem/ScreenHeader.swift`
- Create: `ios/ConstitutionApp/DesignSystem/Badges.swift`

- [ ] **Step 1: `ContentCard.swift`:**
```swift
import SwiftUI

/// The signature parchment card: a 3pt leading accent stripe, hairline border,
/// and trailing-rounded corners. Content is laid out leading-aligned.
struct ContentCard<Content: View>: View {
    var accent: Color = .accentGreen
    @ViewBuilder var content: Content

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0,
                               bottomTrailingRadius: 8, topTrailingRadius: 8)
    }

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(accent).frame(width: 3)
            VStack(alignment: .leading, spacing: 6) { content }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .clipShape(shape)
        .overlay(shape.stroke(Color.cardBorder, lineWidth: 0.5))
    }
}
```

- [ ] **Step 2: `ScreenHeader.swift`:**
```swift
import SwiftUI

/// Serif H1 + optional sans subtitle, shown at the top of a screen's scroll
/// content (the native nav bar uses an inline title alongside this).
struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.screenTitle)
                .foregroundStyle(Color.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(AppFont.subtitle)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

- [ ] **Step 3: `Badges.swift`:**
```swift
import SwiftUI

/// Monospace year chip on the surface colour.
struct YearBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(AppFont.monoSmall)
            .foregroundStyle(Color.textSecondary)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 4))
    }
}

/// Uppercase tinted outcome badge (e.g. CARRIED / DEFEATED).
struct OutcomeBadge: View {
    let text: String
    let foreground: Color
    let background: Color
    var body: some View {
        Text(text.uppercased())
            .font(AppFont.badge)
            .tracking(0.5)
            .foregroundStyle(foreground)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(background, in: Capsule())
    }
}
```

- [ ] **Step 4: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit:**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/DesignSystem/ContentCard.swift ios/ConstitutionApp/DesignSystem/ScreenHeader.swift ios/ConstitutionApp/DesignSystem/Badges.swift
git commit -m "feat(ios): add ContentCard, ScreenHeader, and badge components"
```

---

## Task 3: FlowLayout, SectionRefPill, FilterPills

**Files:**
- Create: `ios/ConstitutionApp/DesignSystem/FlowLayout.swift`
- Create: `ios/ConstitutionApp/DesignSystem/SectionRefPill.swift`
- Create: `ios/ConstitutionApp/DesignSystem/FilterPills.swift`

- [ ] **Step 1: `FlowLayout.swift`** (wrapping layout for pills):
```swift
import SwiftUI

/// A simple left-to-right wrapping layout (like CSS flex-wrap), used for rows
/// of section pills.
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxRowWidth = max(maxRowWidth, x - spacing)
        }
        return CGSize(width: min(maxRowWidth, maxWidth), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
```

- [ ] **Step 2: `SectionRefPill.swift`:**
```swift
import SwiftUI
import ConstitutionKit

/// A monospace section-reference chip (e.g. "s 51", "s 51(ii)"). If the
/// reference resolves to a section, it becomes a navigation link to it.
struct SectionRefPill: View {
    let reference: String
    let store: ContentStore

    var body: some View {
        if let section = store.section(reference: reference) {
            NavigationLink(value: section) { pill }
                .buttonStyle(.plain)
        } else {
            pill
        }
    }

    private var pill: some View {
        Text(formatted)
            .font(AppFont.monoSmall)
            .foregroundStyle(Color.accentGreen)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(Color.appSurface, in: Capsule())
    }

    private var formatted: String {
        let bare = reference.hasPrefix("s") ? String(reference.dropFirst()) : reference
        return "s \(bare)"
    }
}
```

- [ ] **Step 3: `FilterPills.swift`:**
```swift
import SwiftUI

/// A row of selectable pills (filter or sort). The selected pill fills with its
/// `activeColor`; others are outlined.
struct FilterPills<Value: Hashable>: View {
    struct Option: Identifiable {
        let id = UUID()
        let title: String
        let value: Value
        var activeColor: Color = .textPrimary
    }

    let options: [Option]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                let isActive = option.value == selection
                Button {
                    selection = option.value
                } label: {
                    Text(option.title)
                        .font(AppFont.subtitle.weight(.medium))
                        .foregroundStyle(isActive ? Color.white : Color.textSecondary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(isActive ? option.activeColor : Color.appBackground, in: Capsule())
                        .overlay(Capsule().stroke(Color.cardBorder, lineWidth: isActive ? 0 : 0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
```

- [ ] **Step 4: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit:**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/DesignSystem/FlowLayout.swift ios/ConstitutionApp/DesignSystem/SectionRefPill.swift ios/ConstitutionApp/DesignSystem/FilterPills.swift
git commit -m "feat(ios): add FlowLayout, SectionRefPill, and FilterPills"
```

---

## Task 4: Restyle ReferendumListView

**Files:**
- Modify (full replacement): `ios/ConstitutionApp/Referendums/ReferendumListView.swift`

- [ ] **Step 1: Replace the file:**
```swift
import SwiftUI
import ConstitutionKit

struct ReferendumListView: View {
    let store: ContentStore

    enum Filter: Hashable { case all, carried, defeated }
    @State private var filter: Filter = .all

    private var sorted: [Referendum] { store.referendums.sorted { $0.year < $1.year } }
    private var carriedCount: Int { store.referendums.filter { $0.outcome == "carried" }.count }
    private var defeatedCount: Int { store.referendums.filter { $0.outcome == "defeated" }.count }

    private var filtered: [Referendum] {
        switch filter {
        case .all: return sorted
        case .carried: return sorted.filter { $0.outcome == "carried" }
        case .defeated: return sorted.filter { $0.outcome == "defeated" }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(
                        title: "Referendums",
                        subtitle: "\(store.referendums.count) proposals — \(carriedCount) carried, \(defeatedCount) defeated"
                    )

                    FilterPills(options: [
                        .init(title: "All (\(store.referendums.count))", value: .all),
                        .init(title: "Carried (\(carriedCount))", value: .carried, activeColor: .accentGreen),
                        .init(title: "Defeated (\(defeatedCount))", value: .defeated, activeColor: .accentBurgundy),
                    ], selection: $filter)

                    LazyVStack(spacing: 10) {
                        ForEach(filtered) { referendum in
                            NavigationLink(value: referendum) {
                                ReferendumCard(referendum: referendum, store: store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .navigationTitle("Referendums")
            .navigationBarTitleDisplayMode(.inline)
            .contentDestinations(store: store)
        }
    }
}

private struct ReferendumCard: View {
    let referendum: Referendum
    let store: ContentStore

    private var carried: Bool { referendum.outcome == "carried" }

    var body: some View {
        ContentCard(accent: carried ? .accentGreen : .accentBurgundy) {
            HStack {
                YearBadge(text: String(referendum.year))
                Spacer()
                OutcomeBadge(
                    text: referendum.outcome,
                    foreground: carried ? .accentGreen : .accentBurgundy,
                    background: carried ? .tintGreen : .tintBurgundy
                )
            }
            Text(referendum.title)
                .font(AppFont.cardTitle)
                .foregroundStyle(Color.textPrimary)
            Text(referendum.question)
                .font(AppFont.body)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(3)
            HStack(spacing: 12) {
                Text("\(referendum.yesPercentage, specifier: "%.2f")% yes")
                if let f = referendum.statesFor, let a = referendum.statesAgainst {
                    Text("\(f)/\(f + a) states")
                }
            }
            .font(AppFont.mono)
            .foregroundStyle(Color.textSecondary)
            if !referendum.relatedSections.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(referendum.relatedSections, id: \.self) { ref in
                        SectionRefPill(reference: ref, store: store)
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 2: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`. (If `NavigationLink` wrapping a card that itself contains `SectionRefPill` navigation links causes a nested-link warning, that's acceptable for now — the card tap navigates to the referendum; pills navigate to sections. Verify it builds and behaves in Task 6.)

- [ ] **Step 3: Commit:**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Referendums/ReferendumListView.swift
git commit -m "feat(ios): restyle Referendums list with design-system cards"
```

---

## Task 5: Restyle ReferendumDetailView

**Files:**
- Modify (full replacement): `ios/ConstitutionApp/Referendums/ReferendumDetailView.swift`

- [ ] **Step 1: Replace the file:**
```swift
import SwiftUI
import ConstitutionKit

struct ReferendumDetailView: View {
    let store: ContentStore
    let referendum: Referendum

    private var carried: Bool { referendum.outcome == "carried" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        YearBadge(text: referendum.date ?? String(referendum.year))
                        Spacer()
                        OutcomeBadge(
                            text: referendum.outcome,
                            foreground: carried ? .accentGreen : .accentBurgundy,
                            background: carried ? .tintGreen : .tintBurgundy
                        )
                    }
                    Text(referendum.title)
                        .font(AppFont.readingTitle)
                        .foregroundStyle(Color.textPrimary)
                }

                labelled("Question", referendum.question)
                HStack(spacing: 16) {
                    Text("\(referendum.yesPercentage, specifier: "%.2f")% yes")
                    if let f = referendum.statesFor, let a = referendum.statesAgainst {
                        Text("\(f)/\(f + a) states")
                    }
                }
                .font(AppFont.mono)
                .foregroundStyle(Color.textSecondary)

                Text(referendum.content)
                    .font(AppFont.readingBody)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                let sections = store.sections(forReferences: referendum.relatedSections)
                if !sections.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Related Sections")
                            .font(.headline)
                            .foregroundStyle(Color.textPrimary)
                        FlowLayout(spacing: 4) {
                            ForEach(referendum.relatedSections, id: \.self) { ref in
                                SectionRefPill(reference: ref, store: store)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.appBackground)
        .navigationTitle(String(referendum.year))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    @ViewBuilder
    private func labelled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
            Text(value)
                .font(AppFont.body)
                .foregroundStyle(Color.textSecondary)
        }
    }
}
```

- [ ] **Step 2: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit:**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/Referendums/ReferendumDetailView.swift
git commit -m "feat(ios): restyle Referendum detail with design-system styling"
```

---

## Task 6: Verify (light + dark) and confirm the suite is green

- [ ] **Step 1: Build, launch, screenshot the Referendums list (light).**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate
xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
APP=$(find ~/Library/Developer/Xcode/DerivedData -type d -name "ConstitutionApp.app" -path "*Debug-iphonesimulator*" 2>/dev/null | head -1)
xcrun simctl install booted "$APP"
xcrun simctl ui booted appearance light
xcrun simctl launch booted au.constitution.app
sleep 3
xcrun simctl io booted screenshot /tmp/ds-referendums-light.png
```

- [ ] **Step 2: Screenshot dark.**
```bash
xcrun simctl ui booted appearance dark
sleep 1
xcrun simctl io booted screenshot /tmp/ds-referendums-dark.png
xcrun simctl ui booted appearance light
echo "light: /tmp/ds-referendums-light.png  dark: /tmp/ds-referendums-dark.png"
```
Report both paths. The controller inspects: cards with green/burgundy left stripes, year + outcome badges, serif titles, mono stats, wrapped section pills, serif H1 header, filter pills — matching the web look — in both appearances.

- [ ] **Step 3: Confirm the unit suite still passes** (no regressions to the package):
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios/ConstitutionKit && swift test
```
Expected: all tests pass (9).

- [ ] **Step 4: Commit** (only if any fixes were needed in this task; otherwise nothing to commit).

> **CHECKPOINT (controller):** After this task, present the light + dark Referendums screenshots to the user for validation BEFORE writing/executing the follow-up rollout plan. Tune the components here if the look needs adjustment.

---

## Self-Review (completed during authoring)

- **Spec coverage (this plan's scope):** tint Color Sets + `CardBorder` (Task 1) ✓; typography tokens (Task 1) ✓; `ContentCard`/`ScreenHeader`/`YearBadge`/`OutcomeBadge` (Task 2) ✓; `FlowLayout`/`SectionRefPill`/`FilterPills` (Task 3) ✓; Referendums list with serif header + filters + cards + stripes + badges + stats + wrapped pills (Task 4) ✓; Referendum detail restyle (Task 5) ✓; inline nav title + native back + Liquid Glass tab bar retained (unchanged in both views) ✓; `.tabBarMinimizeBehavior` on detail ✓; light+dark verification (Task 6) ✓. Cases/Documents/Chapters/Sections + their details are explicitly deferred to the follow-up plan (validate-exemplar-first strategy).
- **Placeholder scan:** No vague steps; every code step is complete and self-contained.
- **Type consistency:** `ContentCard(accent:content:)`, `ScreenHeader(title:subtitle:)`, `OutcomeBadge(text:foreground:background:)`, `YearBadge(text:)`, `FilterPills(options:selection:)` with `Option(title:value:activeColor:)`, `SectionRefPill(reference:store:)`, `FlowLayout(spacing:)` — signatures defined in Tasks 1–3 match every call site in Tasks 4–5. `Color.tintGreen/tintBurgundy/cardBorder` match the new colorset names. `.contentDestinations(store:)` (Plan 2) reused for navigation. `ConstitutionKit.Section` resolution via `store.section(reference:)` / `store.sections(forReferences:)`.
- **Known acceptable risk:** a `NavigationLink` card containing tappable `SectionRefPill` links is a nested-link pattern; verified behaviourally in Task 6 (card → referendum, pill → section). If it misbehaves, the fallback is to drop pill links inside list cards (keep them only on detail), noted for the checkpoint.
