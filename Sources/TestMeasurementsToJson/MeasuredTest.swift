//
// Created by Ganesh Raman on 24/12/22.
//

import Foundation
import XCTest


extension XCTest {
    func measureAndLog(_ path: String,_ block:() -> Void) {
        let measurerParser = MeasureParser()
        measurerParser.capture(path){ [weak self] in
            guard self != nil else {
                return
            }
            block()
        }

    }
}