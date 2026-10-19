import Foundation
import SwiftData

/// The sample record type. Most one-week apps are a log of something; rename and extend this.
/// Every stored property has a default and nothing is marked unique, which keeps the model
/// CloudKit-compatible if `AppConfig.iCloudSyncEnabled` is turned on later.
@Model
final class Entry {
    var date: Date = Date()
    var title: String = ""
    var value: Double = 0
    var notes: String = ""
    var createdAt: Date = Date()

    init(date: Date = .now, title: String = "", value: Double = 0, notes: String = "") {
        self.date = date
        self.title = title
        self.value = value
        self.notes = notes
        self.createdAt = .now
    }
}

extension Entry {
    /// The calendar day this entry belongs to, used for grouping in the list.
    var day: Date { Calendar.current.startOfDay(for: date) }
}
