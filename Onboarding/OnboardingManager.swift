import SwiftUI
import TipKit

@available(iOS 17, *)
final class OnboardingManager: ObservableObject {
    enum Step: Int, CaseIterable {
        case homeUser, homeCaregiver, homeSettings
        case dot, dash, space, send, mic
    }

    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("onboardingStep") private var storedStep = Step.homeUser.rawValue

    @Published var currentStep: Step

    init() {
        currentStep = Step(rawValue: storedStep) ?? .homeUser
    }

    var isCompleted: Bool {
        onboardingCompleted
    }

    func advance() {
        if let next = Step(rawValue: currentStep.rawValue + 1) {
            currentStep = next
            storedStep = next.rawValue
        } else {
            onboardingCompleted = true
        }
    }

    func reset() {
        onboardingCompleted = false
        currentStep = .homeUser
        storedStep = currentStep.rawValue
    }
}
