import XCTest
@testable import TestMeasurementsToJson

final class TestMeasurementsToJsonTests: XCTestCase {
    func testExample() throws {
        self.measureAndLog {
            self.measure(metrics: [XCTCPUMetric(), XCTClockMetric(), XCTMemoryMetric(), XCTStorageMetric()]) {
                (0...10000).forEach { _ in
                    XCTAssertTrue(true)
                }

            }
        }

    }
}
