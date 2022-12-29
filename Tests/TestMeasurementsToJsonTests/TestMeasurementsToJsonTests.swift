import XCTest
@testable import TestMeasurementsToJson

final class TestMeasurementsToJsonTests: XCTestCase {
    func testExample() throws {
        self.measureAndLog("testLog") {
            self.measure {
                (0...10000).forEach { _ in
                    XCTAssertTrue(true)
                }
            }
        }
    }
    func testFM(){
        do {
            let dir: URL = FileManager.default.temporaryDirectory
            let url = dir.appendingPathComponent("logFile.txt")
            try "Test \(Date())".appendLineToURL(fileURL: url as URL)
            _ = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
        }
        catch {
            XCTAssertTrue(false)
        }
    }
}
