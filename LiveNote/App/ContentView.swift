import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("liveNote.fullText") private var note = ""
    @FocusState private var editing: Bool
    @State private var publishing = false
    @State private var status = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("LiveNote")
                    .font(.system(size: 34, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nội dung ghi chú")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("Nhập ghi chú của bạn…")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $note)
                            .font(.system(size: 19))
                            .scrollContentBackground(.hidden)
                            .padding(7)
                            .focused($editing)
                            .accessibilityLabel("Nội dung ghi chú")
                            .frame(height: 225)
                    }
                    .background(Color(white: 0.13), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.07)))
                }
                Button(action: publish) {
                    HStack {
                        if publishing { ProgressView().tint(.white) }
                        Text(publishing ? "Đang cập nhật…" : "Cập nhật Live Note")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundStyle(.white)
                    .background(Color(red: 0.04, green: 0.46, blue: 0.96), in: RoundedRectangle(cornerRadius: 13))
                }
                .buttonStyle(.plain)
                .disabled(publishing || note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(publishing || note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                if !status.isEmpty {
                    Text(status).font(.footnote).foregroundStyle(.secondary)
                        .accessibilityLabel(status)
                }
            }
            .padding(22)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(white: 0.055).ignoresSafeArea())
        .preferredColorScheme(.dark)
        .alert("Không thể cập nhật", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func publish() {
        guard !publishing else { return }
        let snapshot = note
        publishing = true
        editing = false
        status = ""
        Task { @MainActor in
            defer { publishing = false }
            do {
                try await ActivityManager.publish(snapshot)
                status = "Đã gửi cập nhật. Vuốt lên hoặc khóa máy để xem ghi chú."
                // Wait for ActivityKit to accept the change before attempting Home.
                try? await Task.sleep(nanoseconds: 300_000_000)
                AutoHome.attempt()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

private enum AutoHome {
    @MainActor static func attempt() {
        #if SIDELOAD_AUTO_HOME
        // Private UIKit selector: personal sideload experiment ONLY.
        // No public API sends an iOS app to Home. Do not submit this to App Store.
        // If absent, the app stays open and the on-screen status gives the fallback.
        let app = UIApplication.shared
        let selector = NSSelectorFromString("suspend")
        if app.responds(to: selector) {
            _ = app.perform(selector)
        }
        #endif
    }
}
