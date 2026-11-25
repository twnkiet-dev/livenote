import ActivityKit
import Foundation

struct NoteAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var text: String
    }
    var sessionID: String
}
