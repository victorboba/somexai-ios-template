import AppIntents
import Foundation

/// "Log an entry in <App>" from Siri, Spotlight or the Shortcuts app. Opens the app straight to a new entry.
struct LogEntryIntent: AppIntent {
    static var title: LocalizedStringResource = "Log an Entry"
    static var description = IntentDescription("Opens the app ready to record a new entry.")
    static var openAppWhenRun = true

    static let pendingKey = "intent.openNewEntry"

    func perform() async throws -> some IntentResult {
        WidgetSnapshot.defaults.set(true, forKey: Self.pendingKey)
        return .result()
    }
}

struct SomexAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogEntryIntent(),
            phrases: ["Log an entry in \(.applicationName)", "New entry in \(.applicationName)"],
            shortTitle: "Log Entry",
            systemImageName: "plus.circle"
        )
    }
}
