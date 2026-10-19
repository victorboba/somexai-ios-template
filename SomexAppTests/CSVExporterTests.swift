import XCTest
@testable import SomexApp

final class CSVExporterTests: XCTestCase {
    func testQuotesAndEscapesFields() {
        XCTAssertEqual(CSVExporter.quote(#"say "hi""#), #""say ""hi""""#)
    }

    func testFormatsWholeNumbersWithoutDecimals() {
        XCTAssertEqual(CSVExporter.formatted(3), "3")
        XCTAssertEqual(CSVExporter.formatted(2.5), "2.5")
    }

    @MainActor
    func testCSVHasHeaderAndOneLinePerEntry() {
        let entries = [
            Entry(date: Date(timeIntervalSince1970: 0), title: "First", value: 1, notes: "a, b"),
            Entry(date: Date(timeIntervalSince1970: 60), title: "Second", value: 2.5, notes: ""),
        ]
        let csv = CSVExporter.csv(for: entries)
        let lines = csv.split(separator: "\n")
        XCTAssertEqual(lines.count, 3)
        XCTAssertEqual(lines[0], "date,title,value,notes")
        XCTAssertTrue(lines[1].contains("\"First\",\"1\",\"a, b\""))
    }
}
