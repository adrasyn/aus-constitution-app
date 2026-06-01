# Australian Constitution — iOS app

Native SwiftUI app (iOS 26, Liquid Glass) for browsing the Australian
Constitution, landmark cases, referendums, and historical documents. Content is
the repo's shared `../content/*.json`, bundled as a folder reference, so the web
app and iOS app stay in sync.

## Project layout

- `ConstitutionKit/` — Foundation-only Swift package: models, `ContentStore`,
  `SearchIndex`, `ShareText`, `SpotlightID`. Unit-tested (`swift test`).
- `ConstitutionApp/` — the SwiftUI app target.
- `project.yml` — [XcodeGen](https://github.com/yonsang/XcodeGen) spec. The
  `.xcodeproj` is **generated** (git-ignored), not committed.

## Prerequisites

- Xcode 26+ (`xcode-select -p` should point at `Xcode.app`).
- XcodeGen: `brew install xcodegen`.

## Generate the Xcode project

```bash
cd ios
xcodegen generate
open ConstitutionApp.xcodeproj
```
Re-run `xcodegen generate` after changing `project.yml` or adding/removing files.

## Run in the Simulator

In Xcode pick an iPhone simulator and press ⌘R. Or from the command line:

```bash
xcodebuild -project ConstitutionApp.xcodeproj -scheme ConstitutionApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

## Install on your own iPhone (free Apple ID — no paid account)

You can run the app on a physical iPhone for **7 days** using free provisioning:

1. Your iPhone must be on **iOS 26+** (the deployment target).
2. In Xcode: **Settings → Accounts → +** and sign in with your **Apple ID**
   (free — no paid Developer Program needed).
3. Select the **ConstitutionApp** target → **Signing & Capabilities**:
   - Tick **Automatically manage signing**.
   - **Team** → choose your personal team (`Your Name (Personal Team)`).
   - If the bundle id `au.constitution.app` is rejected as taken, change
     **PRODUCT_BUNDLE_IDENTIFIER** to something unique (e.g.
     `au.constitution.app.<yourname>`).
4. Plug in the iPhone, **Trust** the computer on the device, select it as the
   run destination, and press **⌘R**.
5. First launch on device: on the iPhone go to **Settings → General → VPN &
   Device Management**, tap your Apple ID, and **Trust** it. Re-launch the app.

> **XcodeGen gotcha:** `xcodegen generate` regenerates the `.xcodeproj` and will
> **wipe a Team you set in Xcode**. To make signing survive regeneration, add
> your 10-character Team ID to `project.yml` under the target's
> `settings.base` instead:
> ```yaml
>         DEVELOPMENT_TEAM: ABCDE12345
>         CODE_SIGN_STYLE: Automatic
> ```
> (Find your Team ID in Xcode → Settings → Accounts → your account.)

Free-provisioned builds expire after 7 days — re-run from Xcode to refresh.

## Tests

```bash
cd ConstitutionKit && swift test
```

## Not yet done

- App Store submission (needs a paid Apple Developer account): store listing,
  screenshots, and final review. The app icon and a privacy manifest
  (`PrivacyInfo.xcprivacy`) are already in place.
- Home-screen widget (deliberately skipped).
