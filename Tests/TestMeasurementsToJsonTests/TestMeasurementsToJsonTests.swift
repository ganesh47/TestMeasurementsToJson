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
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let url = dir.appendingPathComponent("logFile.txt")
            try "Test \(Date())".appendLineToURL(fileURL: url as URL)
            let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
        }
        catch {
            XCTAssertTrue(false)
        }
    }
}
