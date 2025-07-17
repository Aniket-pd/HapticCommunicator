import SwiftUI

/// Preference key used to pass the frame of a view up the hierarchy for onboarding highlights.
struct ViewFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    /// Records this view's frame for onboarding using the provided identifier.
    func onboardingTarget(id: String) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: ViewFramePreferenceKey.self, value: [id: proxy.frame(in: .global)])
            }
        )
    }
}
