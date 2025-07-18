import SwiftUI
import TipKit

@MainActor
class OnboardingManager: ObservableObject {
    enum Step: Int, CaseIterable {
        case dot, dash, space, decode, mic
    }

    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @Published var currentStep: Step?

    init() {
        currentStep = onboardingCompleted ? nil : .dot
    }

    func advance() {
        guard let step = currentStep else { return }
        if step == Step.allCases.last {
            complete()
        } else {
            currentStep = Step(rawValue: step.rawValue + 1)
        }
    }

    func skip() {
        complete()
    }

    func replay() {
        onboardingCompleted = false
        currentStep = .dot
    }

    private func complete() {
        onboardingCompleted = true
        currentStep = nil
    }
}

// MARK: - Tips

struct DotTip: Tip {
    var title: Text { Text("Tap anywhere to send a dot") }
}

struct DashTip: Tip {
    var title: Text { Text("Hold anywhere to send a dash") }
}

struct SpaceTip: Tip {
    var title: Text { Text("Swipe right to add space") }
}

struct DecodeTip: Tip {
    var title: Text { Text("Swipe up to decode message") }
}

struct MicTip: Tip {
    var title: Text { Text("Long press anywhere to enable microphone") }
}
