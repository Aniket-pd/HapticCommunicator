import SwiftUI
import TipKit

/// Tracks onboarding progress and manages TipKit tips.
final class OnboardingManager: ObservableObject {
    /// UserDefaults flag so the tutorial only appears once.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    /// All tutorial steps in order.
    private let tips: [AnyTip] = [
        AnyTip(TapDotTip()),
        AnyTip(TapDashTip()),
        AnyTip(SpaceTip()),
        AnyTip(SendTip()),
        AnyTip(MicTip())
    ]

    /// Currently visible step index, `nil` when tutorial is hidden.
    @Published var stepIndex: Int? = nil

    init() {
        if !hasSeenOnboarding {
            stepIndex = 0
        }
    }

    /// Returns the active tip for the current step.
    var currentTip: AnyTip? {
        guard let index = stepIndex, index < tips.count else { return nil }
        return tips[index]
    }

    /// Advances to the next tip or dismisses the tutorial.
    func advance() {
        guard let index = stepIndex else { return }
        let next = index + 1
        if next < tips.count {
            stepIndex = next
        } else {
            stepIndex = nil
            hasSeenOnboarding = true
        }
    }
}

// MARK: - Individual tips

struct TapDotTip: Tip {
    var title: Text { Text("Tap Dot") }
    var message: Text? { Text("Single tap anywhere for a dot.") }
    var options: Tip.Options { Tip.Options(displayFrequency: .once) }
}

struct TapDashTip: Tip {
    var title: Text { Text("Long Press Dash") }
    var message: Text? { Text("Hold your finger to enter a dash.") }
    var options: Tip.Options { Tip.Options(displayFrequency: .once) }
}

struct SpaceTip: Tip {
    var title: Text { Text("Insert Space") }
    var message: Text? { Text("Swipe right to add a letter gap.") }
    var options: Tip.Options { Tip.Options(displayFrequency: .once) }
}

struct SendTip: Tip {
    var title: Text { Text("Send Message") }
    var message: Text? { Text("Swipe up to decode your Morse input.") }
    var options: Tip.Options { Tip.Options(displayFrequency: .once) }
}

struct MicTip: Tip {
    var title: Text { Text("Enable Mic") }
    var message: Text? { Text("Long press anywhere to dictate instead of tapping.") }
    var options: Tip.Options { Tip.Options(displayFrequency: .once) }
}

