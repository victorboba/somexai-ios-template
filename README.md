# SomexAI iPhone Template

A starting point for small, single-purpose iPhone apps: native SwiftUI and SwiftData, iOS 17+, no backend and no accounts. Clone it with one script, edit one config file, replace the sample model, ship.

About 30 apps were built from it; they are linked from [somexai-ios-apps](https://github.com/victorboba/somexai-ios-apps).

## What is in the box

| Piece | Where | Notes |
|---|---|---|
| Access gate | `SomexApp/App/RootView.swift` | A single gate: onboarding once, then a hard paywall until entitled, then the app. |
| Purchases | `SomexApp/Core/Store/EntitlementStore.swift` | StoreKit 2. Two products: an annual subscription with a store-managed free trial and a lifetime non-consumable. Either entitles. |
| Paywall | `SomexApp/Features/Paywall/PaywallView.swift` | Two plans, restore, privacy and terms links. Cannot be dismissed. |
| Local StoreKit config | `SomexApp/StoreKit/Products.storekit` | Buy and test in the simulator with no store setup. Wired into the scheme. |
| Data | `SomexApp/Models/Entry.swift` | SwiftData sample model shaped for CloudKit (every property defaulted). Sync is off by default (`AppConfig.iCloudSyncEnabled`). |
| Core loop | `SomexApp/Features/Home/` | List grouped by day, add/edit sheet, swipe to delete, empty state. |
| Onboarding | `SomexApp/Features/Onboarding/` | Pages driven by `AppConfig.onboarding`. |
| How-to guide | `SomexApp/Features/Help/HowToView.swift` | Step-by-step guide driven by `AppConfig.howTo`. |
| Export | `SomexApp/Core/Export/` | CSV and paginated PDF, shared through the system share sheet. |
| Photos | `SomexApp/Core/Photos/PhotoField.swift` | Add or take a photo for a record. |
| Review prompt | `SomexApp/Core/Review/ReviewPrompter.swift` | Asks after N successful saves, once per version. |
| Widget | `SomexAppWidget/` | Small and medium widget reading a snapshot from the App Group. |
| App Shortcut | `SomexApp/Core/Intents/LogEntryIntent.swift` | "Log an entry in <App>" opens the app on a new entry. |
| Settings | `SomexApp/Features/Settings/` | Plan status, manage subscription, restore, delete all data, rate, support, privacy policy, terms, version, and a Debug section with a paywall bypass. |
| Config | `Shared/AppConfig.swift` | The one file that changes per app: name, copy, product IDs, links, onboarding, paywall benefits, How-to steps, disclaimer. |
| Tests | `SomexAppTests/` | Export and template-rule tests; add one per calculator or rule an app introduces. |

## Make a new app

```bash
scripts/new-app.sh <slug> "<Display Name>" [ModuleName]
scripts/new-app.sh oit-diary "OIT Dose Diary"
```

The slug is lowercase letters, digits and hyphens. The script copies the template to a sibling folder `somexai-<slug>`, renames `SomexApp` to the module name (default: the display name without spaces), sets the bundle ID to `com.example.<slug>` and the product IDs to `com.example.<slug-without-hyphens>.pro.annual` and `.pro.lifetime`, then runs `xcodegen generate`. Display names cannot contain a colon or an ampersand.

Then, in the new folder:

1. Edit `Shared/AppConfig.swift`: app name, entry noun, onboarding copy, paywall benefits, How-to steps, support email, privacy URL.
2. Set prices in `<Module>/StoreKit/Products.storekit`.
3. Rename and reshape `Models/Entry.swift`. Keep every property defaulted (a CloudKit rule).
4. Replace the sample list and editor in `Features/Home/` with the app's real core loop.
5. Adjust the columns in `Core/Export/PDFExporter.swift` so the report reads like the document the user hands over.
6. Make an icon with `scripts/make-appicon.sh`; see [docs/icons.md](docs/icons.md) for the arguments and rules (light, dark and tinted appearances).
7. Run from Xcode (Cmd-R) so the scheme attaches the local StoreKit file. Launching the built app any other way skips it and the paywall stays on "Loading prices".

## Build and run

- Requirements: Xcode 26 or later, [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`), iOS 17 or later.
- Run `xcodegen generate`, open `SomexApp.xcodeproj`, pick the `SomexApp` scheme and an iPhone simulator, and Run.
- Tests: `xcodebuild -scheme SomexApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' test`. `scripts/ci.sh <Scheme> [simulator-name]` is an alternative that keeps DerivedData under `build/` and gives each concurrent run its own simulator.
- Paywall: the app has a hard paywall. Running from Xcode uses the bundled `Products.storekit`, so purchases are simulated and free. Debug builds can skip it with the `-unlock` launch argument or the Debug switch in Settings.
- To run on your own device or ship an app: set your team in `project.yml` (`DEVELOPMENT_TEAM`), change the `com.example` bundle ID prefix in `project.yml`, both `.entitlements` files and `Products.storekit`, and update `supportEmail`, `privacyPolicyURL` and `appStoreID` in `Shared/AppConfig.swift`.
- For a store release, create one annual subscription (with an introductory free trial) and one non-consumable with the product IDs above.

## Rules the template follows

- One gate. Feature views never check entitlement; `RootView` decides what is on screen.
- No free tier, no daily limits, no partial access: trial, then paid.
- Store-managed trials only (the introductory offer on the annual plan), no app-managed trials.
- No accounts. Nothing leaves the device unless the user exports it.
- Apps that touch health log what a clinician prescribed. They never compute a dose, a taper or a diagnosis.

## Project layout

- `SomexApp/`: the app (`App/`, `Core/`, `Features/`, `Models/`, `StoreKit/`).
- `SomexAppWidget/`: the widget.
- `SomexAppTests/`: unit tests.
- `Shared/AppConfig.swift`: everything that changes per app. `Shared/WidgetSnapshot.swift` is the data passed to the widget.
- `scripts/`: `new-app.sh`, `ci.sh`, icon and screenshot helpers.
- `docs/`: [capabilities.md](docs/capabilities.md) (App Group, iCloud) and [icons.md](docs/icons.md).

## License

MIT. See [LICENSE](LICENSE).
