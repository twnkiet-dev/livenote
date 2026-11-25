import ActivityKit
import Foundation

@MainActor
struct ActivityManager {
    enum PublishError: LocalizedError {
        case disabled
        var errorDescription: String? {
            "Live Activities đang bị tắt. Hãy bật trong Cài đặt của iPhone rồi thử lại."
        }
    }

    static func publish(_ text: String) async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw PublishError.disabled
        }
        let state = NoteAttributes.ContentState(text: NoteText.payload(text))
        let content = ActivityContent(state: state, staleDate: nil)
        let existing = Activity<NoteAttributes>.activities
        let active = existing.filter { $0.activityState == .active || $0.activityState == .stale }
        if let current = active.first {
            await current.update(content)
            // Keep only one live note if duplicates ever occur.
            for duplicate in active.dropFirst() {
                await duplicate.end(nil, dismissalPolicy: .immediate)
            }
        } else {
            _ = try Activity<NoteAttributes>.request(
                attributes: NoteAttributes(sessionID: UUID().uuidString),
                content: content,
                pushType: nil
            )
        }
    }
}
