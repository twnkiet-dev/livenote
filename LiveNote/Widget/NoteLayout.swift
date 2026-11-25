import SwiftUI
import UIKit

// Measure wrapped text at each candidate font size rather than just shrinking
// after SwiftUI has already truncated it. Limit both physical and logical lines.
struct NoteLayout {
    var lines: [String]
    var fontSize: CGFloat
    var lineHeight: CGFloat

    static func fit(_ text: String, width: CGFloat, height: CGFloat) -> NoteLayout {
        let text = NoteText.firstTenLines(text)
        let usableWidth = max(1, width - 2) // tiny allowance for font-rendering differences
        let usableHeight = max(1, height)
        var last = NoteLayout(lines: [], fontSize: 10, lineHeight: 12)
        for size in stride(from: 40, through: 10, by: -1) {
            let font = UIFont.systemFont(ofSize: CGFloat(size), weight: .regular)
            let rowHeight = ceil(font.lineHeight)
            let lines = wrap(text, font: font, width: usableWidth)
            let maxRows = max(1, min(10, Int(usableHeight / rowHeight)))
            if lines.count <= maxRows {
                return NoteLayout(lines: lines, fontSize: CGFloat(size), lineHeight: rowHeight)
            }
            var clipped = Array(lines.prefix(maxRows))
            if !clipped.isEmpty {
                var tail = clipped.removeLast()
                while !tail.isEmpty && ((tail + "…") as NSString).size(withAttributes: [.font: font]).width > usableWidth {
                    tail.removeLast()
                }
                clipped.append(tail + "…")
            }
            last = NoteLayout(lines: clipped, fontSize: CGFloat(size), lineHeight: rowHeight)
        }
        return last
    }

    private static func wrap(_ text: String, font: UIFont, width: CGFloat) -> [String] {
        // Separate explicit rows to retain interior blank lines, including Vietnamese text.
        text.components(separatedBy: "\n").flatMap { paragraph -> [String] in
            guard !paragraph.isEmpty else { return [""] }
            let storage = NSTextStorage(string: paragraph, attributes: [.font: font])
            let manager = NSLayoutManager()
            let container = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
            container.lineFragmentPadding = 0
            container.lineBreakMode = .byWordWrapping
            manager.addTextContainer(container)
            storage.addLayoutManager(manager)
            manager.ensureLayout(for: container)
            let glyphs = manager.glyphRange(for: container)
            var lines: [String] = []
            let ns = paragraph as NSString
            manager.enumerateLineFragments(forGlyphRange: glyphs) { _, _, _, glyphRange, _ in
                let chars = manager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
                lines.append(ns.substring(with: chars))
            }
            return lines.isEmpty ? [paragraph] : lines
        }
    }
}

struct FittedNoteView: View {
    var text: String
    var body: some View {
        GeometryReader { geometry in
            let layout = NoteLayout.fit(text, width: geometry.size.width, height: geometry.size.height)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(layout.lines.enumerated()), id: \.offset) { _, line in
                    Text(verbatim: line.isEmpty ? " " : line)
                        .font(.system(size: layout.fontSize, weight: .regular))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: layout.lineHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .clipped()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: NoteText.firstTenLines(text)))
    }
}
