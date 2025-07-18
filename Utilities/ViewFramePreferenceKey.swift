import SwiftUI

/// Preference key used to capture frames of SwiftUI views so they can be
/// highlighted by the onboarding tutorial.
struct ViewFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

extension View {
    /// Assigns an identifier whose global frame will be reported via a
    /// `ViewFramePreferenceKey`.
    func captureFrame(id: String) -> some View {
        background(GeometryReader { geometry in
            Color.clear.preference(key: ViewFramePreferenceKey.self,
                                   value: [id: geometry.frame(in: .global)])
        })
    }
}
