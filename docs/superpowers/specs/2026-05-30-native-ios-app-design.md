# Australian Constitution — Native iOS App Design

**Date:** 2026-05-30
**Status:** Approved (pending spec review)

## Goal

Ship the Australian Constitution reference app to the Apple App Store as a
fully native SwiftUI application, built with the latest iOS 26 Liquid Glass
design language. The existing Next.js web app remains; the iOS app is a
separate native client that reuses the same JSON content as its single source
of truth.

## Decisions

| Decision | Choice |
|----------|--------|
| Approach | Full native SwiftUI rebuild (not Capacitor/React Native) |
| Design fidelity | Full iOS-native redesign — keep content + brand colours, rethink UI around pure iOS conventions |
| Design language | iOS 26 **Liquid Glass** (built with the Xcode 26 / iOS 26 SDK) |
| Devices | iPhone only, portrait |
| Minimum OS | **iOS 26+** (no legacy-appearance fallback code) |
| Appearance | Light **and** dark |
| Search | Global search across all content, results grouped by type |
| Saved items | Everything — sections, cases, referendums, documents |
| Native extras | Share sheet, Dynamic Type + accessibility, Spotlight indexing, home-screen widget |

## 1. Repo layout & content single-sourcing

A new `ios/` directory at the repo root holds the Xcode project. The existing
`content/*.json` files are added to the iOS bundle as **folder references**, so
the JSON stays the single source of truth shared by both the web app and the
iOS app — content is edited once and both clients consume it.

```
aus-constitution-app/
├── app/                 # existing Next.js web app
├── content/             # shared JSON (single source of truth)
│   ├── constitution/{chapters,sections}.json
│   ├── cases/cases.json
│   ├── referendums/referendums.json
│   └── documents/documents.json
└── ios/                 # NEW
    ├── ConstitutionApp.xcodeproj
    ├── ConstitutionApp/      # app target
    ├── ConstitutionWidget/   # widget extension target
    └── ConstitutionKit/      # shared local Swift package
```

## 2. Shared Swift package — `ConstitutionKit`

Models, content loading, and search live in a local Swift package consumed by
**both** the app target and the widget target, so logic is not duplicated.

- **Codable models** mirroring `lib/types.ts`: `Section`, `Chapter`, `Case`,
  `Referendum`, `HistoricalDocument`. Decoding replicates the normalisation
  quirks in `lib/content.ts`:
  - section `id` = `s{number}` (sections JSON keys on a loose `number`/`id`)
  - chapter section list = flatten `parts[].sections`, falling back to
    `chapter.sections` when `parts` is empty
  - defaulted enums (`Case.outcome` → `majority`, `Referendum.outcome` →
    `defeated`)
- **`ContentStore`** — loads & decodes all five JSON files once at launch and
  exposes the relational lookups the web app has: `section(id:)`,
  `sections(forChapter:)`, `casesForSection(_:)`, `referendumsForSection(_:)`,
  `case(id:)`, `referendum(id:)`, `document(id:)`, etc.

## 3. Navigation & screens (Liquid Glass, native redesign)

Root `TabView` using the new iOS 26 `Tab` API. The tab bar and all navigation
chrome render as Liquid Glass automatically because the app is built against the
iOS 26 SDK. SF Symbols for tab icons; large navigation titles.

Tabs:
- **Constitution** (`book`) → Chapters list → Sections list → Section detail
- **Cases** (`building.columns`) → Case detail
- **Documents** (`doc.text`) → Document detail
- **Saved** (`bookmark`) → grouped saved items
- **Search** (`Tab(role: .search)`) — rendered **separated** from the other
  tabs and morphing into a search field (see §4)

Each tab is its own `NavigationStack`.

**Reading behaviour:** detail/reading screens apply
`.tabBarMinimizeBehavior(.onScrollDown)` so the Liquid Glass tab bar shrinks
away while reading long constitution text and returns on scroll up.

**Referendums entry point (resolved):** No dedicated referendums tab. The
Constitution tab's home screen includes a "Referendums" row that opens the
referendums list; referendums also remain reachable from related-section links.
They are fully searchable and saveable.

**Section detail screen:** serif body text, related cases / referendums /
documents as navigable links, with bookmark toggle and share button in the
toolbar.

**Liquid Glass usage rule (per Apple HIG):** glass is applied to navigation
bars, toolbars, the tab bar, and bespoke floating controls only — **never** on
content or scrollable reading surfaces. Parchment reading views stay solid.
`.tabViewBottomAccessory` is intentionally **out of scope for v1**.

## 4. Global search

Implemented as the dedicated `Tab(role: .search)`. Selecting it presents a
full-screen search experience with `.searchable`; results are **grouped by
type** (Sections / Cases / Referendums / Documents) and link into the relevant
detail screen.

Backed by an in-memory index built at launch inside `ConstitutionKit` —
tokenised, case-insensitive prefix/substring matching over titles, body
content, and citations. This is a small native replacement for the web app's
FlexSearch. Input is debounced.

## 5. Persistence — Saved (SwiftData)

A SwiftData model stored on-device:

```swift
@Model final class SavedItem {
    var contentID: String      // e.g. "s51", a case id, etc.
    var type: SavedType        // .section | .case | .referendum | .document
    var dateAdded: Date
}
```

The Saved tab queries SwiftData and resolves each entry back to live content via
`ContentStore`, displaying items grouped by type. A bookmark toggle is available
on every detail screen.

## 6. Native extras

- **Share sheet** — `ShareLink` producing formatted text: title, section
  number / citation, an excerpt, and attribution.
- **Dynamic Type + accessibility** — semantic, scaled fonts throughout;
  VoiceOver labels on interactive elements; respects Reduce Motion. Essential
  for a text-heavy reference app.
- **Spotlight** — index sections and cases via CoreSpotlight
  (`CSSearchableItem`) at first launch; deep-link back into the correct detail
  screen via `NSUserActivity` / `onContinueUserActivity`.
- **Home-screen widget** — a WidgetKit extension ("Section of the day", chosen
  deterministically by date) that deep-links into the section. Uses the shared
  `ConstitutionKit` package for content. **Built as the final phase** (heaviest
  piece: separate target, shared-package wiring, timeline provider, deep-link
  plumbing).

## 7. Theming — light + dark

Asset-catalog Color Sets with Any/Dark appearances mapping the existing design
tokens:

- **Light:** bg `#F5F0E8`, secondary `#EDE7DB`, text `#3D3229` / `#6B5D4F`,
  accents green `#2E5A4A` / gold `#B8935A` / burgundy `#8B2E2E`.
- **Dark:** warm dark variants (e.g. bg `#1C1814`, surface `#26211B`, text
  `#EDE7DB`, accents lightened to meet WCAG contrast).

Liquid Glass chrome is translucent and samples its backdrop, so it adapts to
light/dark automatically — the work is getting the parchment Color Sets right.
Serif body text in **Georgia** (bundled on iOS) with Dynamic Type scaling; the
system sans for UI chrome.

## 8. Testing — verifiable success criteria

Unit tests in `ConstitutionKit`:
- All five JSON files decode successfully with the expected record counts.
- Cross-references resolve: every `relatedCases` / `relatedSections` /
  `relatedReferendums` / `relatedDocuments` id maps to an existing record.
- Search returns known items for known queries.
- `SavedStore` add / remove / persist round-trips correctly.

## Out of scope (v1)

- iPad / universal layouts
- `.tabViewBottomAccessory` ("now reading" bar)
- Remote content sync (content stays bundled)
- Legacy-appearance fallback for iOS < 26

## Suggested build sequence

1. `ConstitutionKit`: models + `ContentStore` + decoding, with unit tests.
2. App shell: `TabView` with the five tabs and `NavigationStack`s.
3. Browse + detail screens (Constitution, Cases, Documents, Referendums).
4. Liquid Glass polish: tab-bar minimize behaviour, theming Color Sets.
5. Global search (`Tab(role: .search)`) + in-memory index.
6. Saved (SwiftData) + bookmark toggles + share sheet.
7. Dynamic Type / accessibility pass.
8. Spotlight indexing + deep links.
9. Home-screen widget extension.
10. App Store prep (icons, screenshots, privacy, submission).
