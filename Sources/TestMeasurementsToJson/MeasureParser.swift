import Foundation

public class MeasureParser {
    let pipe: Pipe = Pipe()
    let regex: NSRegularExpression?
    let results: NSMutableDictionary = NSMutableDictionary()

    init() {
        self.regex = try? NSRegularExpression(
                pattern: "\\[(Clock Monotonic Time|CPU Time|Memory Peak Physical|Memory Physical|CPU Instructions Retired|Disk Logical Writes|CPU Cycles), (s|kB|kI|kC)\\] average: ([0-9\\.]*),",
                options: .caseInsensitive)
    }

    func capture(completion: @escaping () -> Void) {
        let original = dup(STDERR_FILENO)
        setvbuf(stderr, nil, _IONBF, 0)
        dup2(self.pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        self.pipe.fileHandleForReading.readabilityHandler = { [weak self] handle  in
            guard self != nil else { return }
            let data = handle.availableData
            let str = String(data: data, encoding: .utf8) ?? "<Non-ascii data of size\(data.count)>\n"
            if let self {
                self.fetchAndSaveMetrics(str)
                if let copy = (str as NSString?)?.cString(using: String.Encoding.utf8.rawValue) {
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

    private func fetchAndSaveMetrics(_ str: String) {
        guard let mRegex = self.regex else { return }
        let matches = mRegex.matches(in: str, options: .reportCompletion, range: NSRange(location: 0, length: str.count))
        matches.forEach {
            let nameIndex = Range($0.range(at: 1), in: str)
            let averageIndex = Range($0.range(at: 3), in: str)
            if nameIndex != nil && averageIndex != nil {
                let name = str[nameIndex!]
                let average = str[averageIndex!]
                self.results[name] = average
            }
        }
    }
}