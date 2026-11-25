import ActivityKit
import SwiftUI
import WidgetKit

@main
struct LiveNoteWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoteAttributes.self) { context in
            FittedNoteView(text: context.state.text)
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .frame(height: 156)
                .activityBackgroundTint(.black.opacity(0.88))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    FittedNoteView(text: context.state.text)
                        .frame(height: 92)
                        .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "note.text")
            } compactTrailing: {
                Image(systemName: "text.alignleft")
            } minimal: {
                Image(systemName: "note.text")
            }
            .keylineTint(.white)
        }
    }
}
