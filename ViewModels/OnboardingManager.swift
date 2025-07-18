import SwiftUI

@MainActor
class OnboardingManager: ObservableObject {
    enum Step: Int, CaseIterable {
        case dot, dash, space, send, mic

        var tip: AnyTip {
            switch self {
            case .dot: return AnyTip(DotTip())
            case .dash: return AnyTip(DashTip())
            case .space: return AnyTip(SpaceTip())
            case .send: return AnyTip(SendTip())
            case .mic: return AnyTip(MicTip())
            }
        }
    }

    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    @Published var currentStep: Step? = nil

    init() {
        if !isOnboardingCompleted {
            currentStep = .dot
        }
    }

    func next() {
        guard let step = currentStep else { return }
        let all = Step.allCases
        if let idx = all.firstIndex(of: step), idx + 1 < all.count {
            currentStep = all[idx + 1]
        } else {
            currentStep = nil
            isOnboardingCompleted = true
        }
    }

    func skip() {
        currentStep = nil
        isOnboardingCompleted = true
    }

    func reset() {
        isOnboardingCompleted = false
        currentStep = .dot
    }
}
