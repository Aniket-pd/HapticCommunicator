import SwiftUI

/// Represents a single onboarding step with a target identifier and message.
struct OnboardingStep: Identifiable {
    let id: String
    let message: String
}

/// Manages displaying onboarding steps and tracking completion.
final class OnboardingManager: ObservableObject {
    @Published var currentStepIndex: Int = 0
    @Published var frames: [String: CGRect] = [:]
    @Published var isActive: Bool = false

    private let steps: [OnboardingStep]
    private let defaultsKey = "hasSeenOnboarding"

    init(steps: [OnboardingStep]) {
        self.steps = steps
        if !UserDefaults.standard.bool(forKey: defaultsKey) {
            isActive = true
        }
    }

    var currentStep: OnboardingStep? {
        guard isActive && currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    func advance() {
        currentStepIndex += 1
        if currentStepIndex >= steps.count {
            isActive = false
            UserDefaults.standard.set(true, forKey: defaultsKey)
        }
    }

    /// Updates the stored frame for a target view.
    func updateFrame(id: String, frame: CGRect) {
        frames[id] = frame
    }

    /// The rect for the current onboarding target.
    var currentRect: CGRect {
        guard let step = currentStep, let rect = frames[step.id] else { return .zero }
        return rect
    }
}
