import UIKit

/// A plain, printable report: title, date range, then one row per entry, paginated on US Letter.
/// This is the "hand it to the clinician / inspector / board" feature, so keep it boring and legible.
enum PDFExporter {
    private static let page = CGRect(x: 0, y: 0, width: 612, height: 792)
    private static let margin: CGFloat = 48
    private static let rowHeight: CGFloat = 18

    static func export(_ entries: [Entry], title: String = AppConfig.appName) throws -> URL {
        let url = ExportFile.temporaryURL(extension: "pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let sorted = entries.sorted { $0.date < $1.date }

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 20)]
        let subtitleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.darkGray]
        let headerAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 10)]
        let cellAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10)]

        let columns: [(name: String, x: CGFloat, width: CGFloat)] = [
            ("Date", margin, 120),
            ("Title", margin + 124, 150),
            ("Value", margin + 278, 60),
            ("Notes", margin + 342, page.width - margin - (margin + 342)),
        ]

        try renderer.writePDF(to: url) { context in
            var y: CGFloat = 0
            var pageNumber = 0

            func startPage() {
                context.beginPage()
                pageNumber += 1
                y = margin
                title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
                y += 26
                let range: String
                if let first = sorted.first?.date, let last = sorted.last?.date {
                    range = "\(DateFormatter.report.string(from: first)) to \(DateFormatter.report.string(from: last)) · \(sorted.count) \(sorted.count == 1 ? AppConfig.entryNoun.lowercased() : AppConfig.entryNounPlural.lowercased())"
                } else {
                    range = "No \(AppConfig.entryNounPlural.lowercased()) yet"
                }
                "\(range) · Page \(pageNumber)".draw(at: CGPoint(x: margin, y: y), withAttributes: subtitleAttributes)
                y += 24
                for column in columns {
                    column.name.draw(in: CGRect(x: column.x, y: y, width: column.width, height: rowHeight), withAttributes: headerAttributes)
                }
                y += rowHeight
                context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.move(to: CGPoint(x: margin, y: y - 3))
                context.cgContext.addLine(to: CGPoint(x: page.width - margin, y: y - 3))
                context.cgContext.strokePath()
            }

            startPage()
            for entry in sorted {
                if y > page.height - margin - rowHeight { startPage() }
                let cells = [
                    DateFormatter.report.string(from: entry.date),
                    entry.title,
                    CSVExporter.formatted(entry.value),
                    entry.notes.replacingOccurrences(of: "\n", with: " "),
                ]
                for (column, text) in zip(columns, cells) {
                    text.draw(in: CGRect(x: column.x, y: y, width: column.width, height: rowHeight), withAttributes: cellAttributes)
                }
                y += rowHeight
            }
        }
        return url
    }
}
