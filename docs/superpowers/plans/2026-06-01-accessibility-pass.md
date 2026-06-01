# Accessibility & Dynamic Type Pass — Implementation Plan (Plan 5a)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the app fully usable at large Dynamic Type sizes and with VoiceOver — fix the one non-scaling font, honour Reduce Motion, and give icon-only controls and result rows clear accessibility labels.

**Architecture:** Small, targeted edits — no new types. Verify scaling via simulator screenshots at an accessibility text size.

**Tech Stack:** SwiftUI (iOS 26), XcodeGen.

**Spec:** `docs/superpowers/specs/2026-05-30-native-ios-app-design.md` §6 (Dynamic Type + accessibility).

> **Inherited conventions:** build/screenshot on iPhone 17 Pro sim. The simulator content size can be set with `xcrun simctl ui <udid> content_size <size>` (e.g. `accessibility-extra-extra-extra-large`, `large`). `AppFont` tokens use `Font.custom("Georgia", size:relativeTo:)` (scaling) for titles/reading and system text styles for badges/mono (scaling). The reveal title in `DesignSystem/RevealingNavTitle.swift` currently uses a FIXED-size font. Icon-only controls: `ShareLink` (image only) and the Saved-entry `NavigationLink` (bookmark image) in `ChapterListView` lack labels; `BookmarkButton` already has one.

> **Verification:** SwiftUI accessibility isn't headlessly unit-testable. Each task is gated on `** BUILD SUCCEEDED **`; the controller screenshots at default + accessibility-XXXL text sizes to confirm no clipping and readable scaling. Deep VoiceOver validation is confirmed by the user with VoiceOver enabled. `swift test` (22) stays green.

---

## Task 1: Scaling fonts + Reduce Motion

**Files:** Modify `ios/ConstitutionApp/DesignSystem/AppFont.swift`, `ios/ConstitutionApp/DesignSystem/RevealingNavTitle.swift`

- [ ] **Step 1: Add a scaling nav-title token** to `AppFont.swift` (append inside the enum):
```swift
    /// Serif title used in the nav bar reveal — scales with Dynamic Type.
    static let navTitle = Font.custom("Georgia", size: 16, relativeTo: .headline).weight(.semibold)
```

- [ ] **Step 2: Use it + honour Reduce Motion** in `RevealingNavTitle.swift`. Replace the modifier body so (a) the principal title uses `AppFont.navTitle` instead of the fixed `.system(size: 16, …)`, and (b) the reveal animation is skipped when Reduce Motion is on. Full replacement of the `RevealNavTitleModifier` struct:
```swift
private struct RevealNavTitleModifier: ViewModifier {
    let title: String
    @State private var revealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y > 44
            } action: { _, newValue in
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    revealed = newValue
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(AppFont.navTitle)
                        .foregroundStyle(Color.textPrimary)
                        .opacity(revealed ? 1 : 0)
                        .accessibilityHidden(!revealed)
                }
            }
    }
}
```

- [ ] **Step 3: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp/DesignSystem/AppFont.swift ios/ConstitutionApp/DesignSystem/RevealingNavTitle.swift
git commit -m "feat(ios): scale nav-title font with Dynamic Type and honour Reduce Motion"
```

---

## Task 2: VoiceOver labels + result-row grouping

**Files:** Modify `ios/ConstitutionApp/Constitution/ChapterListView.swift` (Saved entry + share?), the four detail views (ShareLink label), and `ios/ConstitutionApp/DesignSystem/RelatedItemsSection.swift`

- [ ] **Step 1: Label the Saved-entry button** in `ChapterListView.swift`. The toolbar `NavigationLink { SavedView… } label: { Image(systemName: "bookmark") }` — add an accessibility label. Change the label image to:
```swift
                    } label: {
                        Image(systemName: "bookmark")
                    }
                    .tint(.accentGreen)
                    .accessibilityLabel("Saved")
```

- [ ] **Step 2: Label the ShareLink** in each of the four detail views (`SectionDetailView`, `CaseDetailView`, `ReferendumDetailView`, `DocumentDetailView`). Each has:
```swift
                ShareLink(item: ShareText.xxx(...)) {
                    Image(systemName: "square.and.arrow.up")
                }
```
Add `.accessibilityLabel("Share")` to each `ShareLink`:
```swift
                ShareLink(item: ShareText.xxx(...)) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share")
```
(Apply the same one-line addition in all four files, keeping each file's existing `ShareText.<type>(...)` call.)

- [ ] **Step 3: Group related-item rows for VoiceOver** in `RelatedItemsSection.swift`. The `NavigationLink` wrapping the `ContentCard` should read as a single button combining the primary + secondary text. Add `.accessibilityElement(children: .combine)` to the `ContentCard` inside the `ForEach`:
```swift
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
                        .accessibilityElement(children: .combine)
                    }
                    .buttonStyle(.plain)
                }
```
(This is safe — `RelatedItemsSection` rows contain no nested interactive elements. Do NOT apply `.combine` to the Referendum/Case *list* cards, which embed tappable section-ref pills.)

- [ ] **Step 4: Build.** Standard build command. Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app
git add ios/ConstitutionApp
git commit -m "feat(ios): add VoiceOver labels for icon controls and group related rows"
```

---

## Task 3: Verify scaling

- [ ] **Step 1: Build + unit suite**
```bash
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios/ConstitutionKit && swift test
cd /Users/James/Documents/Claude/Projects/aus-constitution-app/ios && xcodegen generate && \
  xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build CODE_SIGNING_ALLOWED=NO
```
Expected: 22 tests pass; `** BUILD SUCCEEDED **`.

- [ ] **Step 2: CONTROLLER Dynamic Type check.** Launch, then screenshot the Constitution home and a detail at a large size and back to default:
```bash
UDID=3727E81D-284D-4147-89CF-DDD85940BD09
APP=$(find ~/Library/Developer/Xcode/DerivedData -type d -name "ConstitutionApp.app" -path "*Debug-iphonesimulator*" | head -1)
xcrun simctl install "$UDID" "$APP"; xcrun simctl launch "$UDID" au.constitution.app; sleep 3
xcrun simctl ui "$UDID" content_size accessibility-extra-extra-extra-large
sleep 1; xcrun simctl io "$UDID" screenshot /tmp/a11y-xxxl.png
xcrun simctl ui "$UDID" content_size large
```
Confirm the home/cards reflow and remain readable (text grows, no hard clipping of titles). Report the screenshot.

---

## Self-Review (completed during authoring)

- **Spec coverage (§6 accessibility):** Dynamic Type — all text uses scaling fonts after fixing the one fixed-size nav-title (Task 1) ✓; Reduce Motion honoured for the reveal (Task 1) ✓; VoiceOver — icon-only controls (Share, Saved) get labels; `BookmarkButton` already had one; related rows read as single buttons (Task 2) ✓.
- **Placeholder scan:** none — concrete edits with full code.
- **Type consistency:** `AppFont.navTitle` defined (Task 1) and used in `RevealingNavTitle` (Task 1). The `ShareLink`/`NavigationLink`/`RelatedItemsSection` edits match the existing code shapes.
- **Scope discipline:** intentionally NOT combining the Referendum/Case list cards (they contain nested tappable pills); broader VoiceOver tuning beyond labels/grouping is deferred for live VoiceOver validation rather than guessed at. Hit-target sizing of small pills is noted but not changed (they're secondary affordances with larger card/list alternatives).
