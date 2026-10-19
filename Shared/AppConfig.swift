import Foundation

/// The one file to edit when starting a new app from this template.
/// Everything user-facing that changes per app (name, copy, product IDs, links) lives here.
/// Compiled into both the app and the widget, so keep it free of UIKit/SwiftUI imports.
enum AppConfig {
    // MARK: Identity
    static let appName = "Somex App"
    static let bundleID = "com.example.template"
    static let appGroupID = "group.com.example.template"
    /// Your App Store ID once the app is live. The Rate button stays hidden while it is empty.(the number in the App Store URL).
    static let appStoreID = ""

    // MARK: Sync
    /// Set to true only after enabling iCloud + CloudKit on the App ID (see docs/capabilities.md).
    /// With false, SwiftData stores locally and the app works with no Apple capabilities at all.
    static let iCloudSyncEnabled = false

    // MARK: StoreKit (must match App Store Connect and StoreKit/Products.storekit)
    /// Apple allows only letters, digits, underscores and periods in product IDs, so hyphens in the bundle ID are dropped.
    static let productPrefix = bundleID.replacingOccurrences(of: "-", with: "")
    static let annualProductID = "\(productPrefix).pro.annual"
    static let lifetimeProductID = "\(productPrefix).pro.lifetime"

    // MARK: Links
    static let supportEmail = "support@somexai.com"
    /// Hosted copy of PrivacyPolicyView, one page per app under somexai.com/privacy (somexai_corp repo, scripts/privacy.py).
    static let privacyPolicyURL = URL(string: "https://somexai.com/privacy/template/")!
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    // MARK: Copy
    /// What the app calls one record. "Entry" for a generic log; "Dose", "Visit", "Inspection" in real apps.
    static let entryNoun = "Entry"
    static let entryNounPlural = "Entries"
    /// File name stem for exports: "somex-app-2026-09-11.csv".
    static let exportFileStem = "somex-app"

    static let onboarding: [OnboardingPage] = [
        OnboardingPage(symbol: "list.bullet.clipboard", title: "Log it in seconds",
                       body: "Tap once to record what happened. No account, no setup."),
        OnboardingPage(symbol: "chart.line.uptrend.xyaxis", title: "See the pattern",
                       body: "Your history is grouped by day so trends are obvious."),
        OnboardingPage(symbol: "square.and.arrow.up", title: "Share a clean report",
                       body: "Export a PDF or CSV for whoever needs it. Your data stays on your phone."),
    ]

    static let paywallSymbol = "checkmark.seal.fill"
    static let paywallHeadline = "Unlock \(appName)"
    static let paywallBenefits = [
        "Unlimited \(entryNounPlural.lowercased())",
        "PDF and CSV export",
        "Home Screen widget and Siri Shortcut",
        "No ads, no account, no tracking",
    ]

    // MARK: How-to guide (Settings → How do I use this app; also the ? button on the home screen)
    static let howToIntro = "Three steps from install to your first export. Each takes under a minute."
    static let howTo: [HowToStep] = [
        HowToStep(symbol: "plus.circle", title: "Add your first \(entryNoun.lowercased())",
                  body: "Tap + on the home screen, fill in the title and value, and save. Entries group by day automatically.",
                  tip: "Say \"Log an entry in \(appName)\" to Siri to open this screen from anywhere."),
        HowToStep(symbol: "pencil", title: "Edit or delete",
                  body: "Tap an entry to change it. Swipe left on a row to delete it."),
        HowToStep(symbol: "square.and.arrow.up", title: "Export a report",
                  body: "Tap the share icon at the top of the home screen and choose PDF or CSV. Send it by Mail, AirDrop or save to Files."),
        HowToStep(symbol: "rectangle.on.rectangle", title: "Add the widget",
                  body: "Long-press your Home Screen, tap +, search \"\(appName)\", and add the small or medium widget."),
    ]

    /// Display prices used only by DEBUG screenshot runs (`-mockPrices`). Keep in sync with StoreKit/Products.storekit.
    static let mockPrices = (annual: "$9.99", lifetime: "$24.99")

    // MARK: Behaviour
    /// Ask for an App Store review after this many successful saves (once per app version).
    static let reviewAfterSuccesses = 3
}

struct HowToStep: Identifiable, Hashable {
    var id: String { title }
    let symbol: String
    let title: String
    let body: String
    var tip: String? = nil
}

struct OnboardingPage: Identifiable, Hashable {
    var id: String { title }
    let symbol: String
    let title: String
    let body: String
}
