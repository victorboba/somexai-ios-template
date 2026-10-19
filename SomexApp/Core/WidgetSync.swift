import Foundation
import WidgetKit

enum WidgetSync {
    /// Recomputes the widget summary from the current entries and reloads timelines.
    static func update(with entries: [Entry]) {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let latest = entries.max { $0.date < $1.date }
        var snapshot = WidgetSnapshot()
        snapshot.totalEntries = entries.count
        snapshot.entriesThisWeek = entries.filter { $0.date >= weekAgo }.count
        snapshot.lastEntryTitle = latest?.title
        snapshot.lastEntryDate = latest?.date
        snapshot.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
