import Foundation

// Store the complete note in the app; send only the visible prefix to ActivityKit.
// A conservative JSON budget leaves room for the other activity fields.
enum NoteText {
    static func firstTenLines(_ text: String) -> String {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{2028}", with: "\n")
            .replacingOccurrences(of: "\u{2029}", with: "\n")
        return normalized.components(separatedBy: "\n").prefix(10).joined(separator: "\n")
    }

    static func payload(_ text: String) -> String {
        let visible = firstTenLines(text)
        let encoder = JSONEncoder()
        func fits(_ value: String) -> Bool {
            (try? encoder.encode(value).count).map { $0 <= 3400 } ?? false
        }
        guard !fits(visible) else { return visible }
        // First bound the number of graphemes, then find a safe encoded prefix.
        let characters = Array(visible.prefix(3400))
        var low = 0
        var high = characters.count
        while low < high {
            let mid = (low + high + 1) / 2
            if fits(String(characters.prefix(mid)) + "…") { low = mid }
            else { high = mid - 1 }
        }
        return String(characters.prefix(low)) + "…"
    }
}
