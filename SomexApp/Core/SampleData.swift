import Foundation
import SwiftData

#if DEBUG
/// Debug-only sample data for screenshots and manual testing. Replace with the app's own realistic history.
/// Launch with `-sampleData` to insert it on first run, or use Settings → Debug → Insert sample data.
enum SampleData {
    static func insert(into context: ModelContext) {
        let calendar = Calendar.current
        let titles = ["Morning check", "Afternoon check", "Evening check"]
        for offset in stride(from: 29, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: .now),
                  let time = calendar.date(bySettingHour: 8 + (offset % 3) * 4, minute: Int.random(in: 0...59), second: 0, of: day) else { continue }
            let entry = Entry(date: time, title: titles[offset % titles.count], value: Double(Int.random(in: 1...9)), notes: offset % 7 == 0 ? "Felt off today." : "")
            context.insert(entry)
        }
    }
}
#endif
