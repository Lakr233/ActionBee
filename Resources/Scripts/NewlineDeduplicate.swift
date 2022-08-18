import Foundation

guard CommandLine.arguments.count == 2 else { exit(-1) }

let url = URL(fileURLWithPath: CommandLine.arguments[1])

guard var str = try? String(contentsOf: url) else { exit(-1) }

while str.contains("\n\n\n") {
    str = str.replacingOccurrences(of: "\n\n\n", with: "\n\n")
}

try str.write(to: url, atomically: true, encoding: .utf8)