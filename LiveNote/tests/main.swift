import Foundation

func check(_ condition: @autoclosure () -> Bool, _ label: String) {
    if !condition() { fatalError(label) }
}
let twelve = (1...12).map { "Dòng \($0)" }.joined(separator: "\n")
check(NoteText.firstTenLines(twelve).components(separatedBy: "\n").count == 10, "line limit")
check(NoteText.firstTenLines(twelve).hasSuffix("Dòng 10"), "first ten")
check(NoteText.firstTenLines("a\r\nb\r\nc") == "a\nb\nc", "CRLF")
check(NoteText.firstTenLines("a\n\nb") == "a\n\nb", "blank line")
check(NoteText.payload("Ghi chú tiếng Việt 📝") == "Ghi chú tiếng Việt 📝", "Vietnamese")
for original in [String(repeating: "👨‍👩‍👧‍👦", count: 1500), String(repeating: "\"\\", count: 4000), String(repeating: "ệ", count: 5000)] {
    let payload = NoteText.payload(original)
    check((try! JSONEncoder().encode(payload)).count <= 3400, "JSON budget")
    check(payload.hasSuffix("…"), "ellipsis")
    check(original.hasPrefix(String(payload.dropLast())), "grapheme prefix")
}
print("All NoteText tests passed")
