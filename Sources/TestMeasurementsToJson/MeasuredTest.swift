//
// Created by Ganesh Raman on 24/12/22.
//

import Foundation
import XCTest


extension XCTest {
    func measureAndLog(_ block: @escaping () -> Void) {
        let measurerParser = MeasureParser()
        measurerParser.capture { [weak self] in
            guard self != nil else {
                return
            }
            block()
        }
        var error : NSError?
        let jsonData = try! JSONSerialization.data(withJSONObject: measurerParser.results, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        print(jsonString)

    }
}