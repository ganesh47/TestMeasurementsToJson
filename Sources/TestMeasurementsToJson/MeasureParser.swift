import Foundation

public class MeasureParser {
    let pipe: Pipe = Pipe()
    let regex: NSRegularExpression?
    let results: NSMutableDictionary = NSMutableDictionary()
    init() {
        regex = try? NSRegularExpression(
                pattern: "measured \\[(.*), (.*)\\] average: ([0-9\\.]*),",
                options: .caseInsensitive)
    }

    func capture(_ path:String, completion: () -> Void) {
        let original = dup(STDERR_FILENO)
        setvbuf(stderr, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            guard self != nil else {
                return
            }
            let data = handle.availableData
            let str = String(data: data, encoding: .utf8) ?? "<Non-ascii data of size\(data.count)>\n"
            if let self {
                self.fetchAndSaveMetrics(path,str)
                if ((str as NSString?)?.cString(using: String.Encoding.utf8.rawValue)) != nil {
                    print("\(str)")
                }
            }

            // Print to stdout because stderr is piped
        }
        completion()
        fflush(stderr)
        dup2(original, STDERR_FILENO)
        close(original)
    }

    private func fetchAndSaveMetrics(_ path:String,_ str: String) {
        guard let mRegex = regex else {
            return
        }
        let matches = mRegex.matches(in: str, options: .reportCompletion, range: NSRange(location: 0, length: str.count))
        matches.forEach {
            let nameIndex = Range($0.range(at: 1), in: str)
            let nameUnits = Range($0.range(at: 2), in: str)
            let averageIndex = Range($0.range(at: 3), in: str)
            if nameIndex != nil && averageIndex != nil {

                let units: String = String(str[nameUnits!])
                let name: String = str[nameIndex!] + " in " + units
                let average = str[averageIndex!]
                results[name] = String(average)
            }
        }
        var _ : NSError?
        let jsonData = try! JSONSerialization.data(withJSONObject: results, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        let dir: URL = FileManager.default.temporaryDirectory
        print("****")
        do {
            try jsonString.appendToURL(fileURL: dir.appendingPathComponent(path))
            print("Saved to \(dir.appendingPathComponent(path))")
        } catch {
            print("Error writing to file")
        }

    }
}