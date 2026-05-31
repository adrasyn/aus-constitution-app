# Content Styling Design System — Design

**Date:** 2026-05-31
**Status:** Approved (direction); to be validated on-screen
**Revises:** `2026-05-30-native-ios-app-design.md` §3/§7 for the **content layer**.

## Goal

Bring the web app's visual character to **all content** in the native iOS app — parchment cards with coloured left stripes, serif headings, mono badges/stats, tinted outcome badges, and section-reference pill chips — while keeping Apple's navigation chrome (nav bars, inline titles, back gestures) and the Liquid Glass tab bar.

This revises the earlier "full iOS-native redesign" decision: the **navigation layer** stays native + Liquid Glass; the **content layer** adopts the web app's styling.

## Decisions

| Decision | Choice |
|----------|--------|
| Title style | Native **inline** nav title + web-style **serif H1** inside the scroll content |
| Filters/sorts | Included (Referendums: All/Carried/Defeated; Cases: sort Year/Name) |
| Container | Content screens use `ScrollView { LazyVStack }` of custom cards (not `List`) |
| Nav + tab bar | Unchanged — native `NavigationStack`, back gestures, Liquid Glass tab bar |
| Scope | All content screens (Constitution chapters/sections/detail, Cases, Referendums, Documents) |

## Design tokens (`DesignSystem/Theme.swift`)

Fonts (Dynamic Type-scaled):
- **Serif** (Georgia): screen H1 (~24pt), card titles (~16pt), section reading body.
- **Sans** (system): subtitles, body/question text, labels (~13pt), uppercase badges (~11pt).
- **Mono** (system monospaced): year badges, stats, section-reference pills (~11–12pt).

Colours — existing palette (`AppBackground`, `AppSurface`, `TextPrimary`, `TextSecondary`, `AccentGreen`, `AccentGold`, `AccentBurgundy`) **plus three new tint Color Sets** with light/dark variants:

| Tint | Light | Dark |
|------|-------|------|
| `TintGreen` | `E8 F0 EC` | `20 30 2A` |
| `TintGold` | `F5 EF E0` | `32 2B 1E` |
| `TintBurgundy` | `F3 EA EA` | `3A 24 24` |

Card shape: surface = `AppBackground`, hairline `border` (~0.5pt) via the existing border colour need — add a `CardBorder` Color Set (`D4C9B8` / `3A332B`); **3pt leading accent stripe**; corners rounded on the trailing side only (radius 8). Card padding 14×16, inter-card spacing 10.

## Components (`DesignSystem/`)

Each is a small, single-purpose view:

- **`ContentCard`** — `init(accent: Color, @ViewBuilder content:)`. Renders the parchment surface, hairline border, 3pt leading accent stripe, trailing-rounded corners. Used by every list/related card.
- **`ScreenHeader`** — `init(title: String, subtitle: String?)`. Serif H1 + sans subtitle. Sits at the top of each list's scroll content.
- **`FilterPills<T: Hashable>`** — generic pill segmented control bound to a `selection`; options carry a label and an "active" tint (neutral dark / green / burgundy). Used for referendum filter and case sort.
- **`YearBadge`** — mono text on `AppSurface`, small radius.
- **`OutcomeBadge`** — uppercase mono/sans, `TintGreen`+`AccentGreen` (carried) or `TintBurgundy`+`AccentBurgundy` (defeated).
- **`SectionRefPill`** — mono chip on `AppSurface`; wrapped in a `NavigationLink(value:)` to the referenced section. Label formatted like the web (`s 51`, `51(ii)`).
- **`FlowLayout`** — wrapping layout (iOS 26 `Layout` protocol) so section pills wrap to multiple rows.
- **`AmendmentNote`** — burgundy-tinted box with left stripe for a section's `notes`.

## Per-screen layouts

All lists: `ScrollView` → `ScreenHeader` → (filters/sort if any) → `LazyVStack` of `ContentCard`s; inline nav title; `.tabBarMinimizeBehavior(.onScrollDown)`.

- **ReferendumListView** — subtitle "{N} proposals — {c} carried, {d} defeated"; `FilterPills` All/Carried/Defeated; cards: year badge + outcome badge row, serif title, sans question (3-line clamp), mono stats ("{yes}% yes · {f}/{f+a} states"), wrapped section pills; **stripe** green (carried) / burgundy (defeated).
- **CaseListView** — subtitle "{N} landmark cases"; sort `FilterPills` Year/Name; cards: year badge + section pills row, serif case name, sans principle (clamp), sans court; stripe green (or burgundy when `outcome == "dissent"`).
- **DocumentListView** — cards: year badge, serif title, sans description; stripe gold.
- **ChapterListView** — cards: serif chapter title, sans "{N} section(s)"; stripe green. (Chapters → SectionListView.)
- **SectionListView** — cards: mono section label ("Section 51" / "Preamble"), serif title; stripe green.
- **SectionDetailView** — serif label + serif title header; serif reading body (`TextPrimary`); `AmendmentNote` if `notes`; related Cases/Referendums/Documents as `ContentCard` rows (serif name + meta), navigable.
- **CaseDetailView / ReferendumDetailView / DocumentDetailView** — serif title header + mono meta (court/citation/year/date) + outcome badge; labelled serif/sans body; related sections as wrapped `SectionRefPill`s or cards; source `Link`.

## Out of scope

Search/Saved/share/Spotlight/widget (later plans). No web-style breadcrumbs (native back replaces them). No AppIcon yet.

## Verification

`** BUILD SUCCEEDED **` plus controller-inspected light **and** dark screenshots of each screen type (list + detail). Tokens/components are the only logic; no new unit tests (pure SwiftUI views + asset catalog). The existing `ContentStore`/`sections(forReferences:)` tests still pass.
