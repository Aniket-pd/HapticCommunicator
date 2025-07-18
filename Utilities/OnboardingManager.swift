import SwiftUI
import TipKit

enum OnboardingStep: Int, CaseIterable {
    case tapDot
    case tapDash
    case addSpace
    case sendDecode
    case enableMic
}

final class OnboardingManager: ObservableObject {
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    @Published var step: OnboardingStep? = nil

    let tapDotTip = TapDotTip()
    let tapDashTip = TapDashTip()
    let addSpaceTip = AddSpaceTip()
    let sendDecodeTip = SendDecodeTip()
    let enableMicTip = EnableMicTip()

    init() {
        [tapDotTip, tapDashTip, addSpaceTip, sendDecodeTip, enableMicTip].forEach { $0.configure() }
        if !isOnboardingCompleted {
            step = .tapDot
            updateParameters()
        }
    }

    /// Returns the tip associated with the current step.
    var activeTip: some Tip {
        switch step {
        case .tapDot: tapDotTip
        case .tapDash: tapDashTip
        case .addSpace: addSpaceTip
        case .sendDecode: sendDecodeTip
        case .enableMic: enableMicTip
        case .none: tapDotTip // default never shown
        }
    }

    /// Advance to the next onboarding step, marking completion when finished.
    func advance() {
        guard let step else { return }
        if step == .enableMic {
            isOnboardingCompleted = true
            self.step = nil
        } else {
            self.step = OnboardingStep(rawValue: step.rawValue + 1)
        }
        updateParameters()
    }

    /// Keep the static parameters on tips in sync with the current step so the
    /// appropriate tip displays.
    private func updateParameters() {
        let value = step?.rawValue ?? -1
        TapDotTip.activeStep = value
        TapDashTip.activeStep = value
        AddSpaceTip.activeStep = value
        SendDecodeTip.activeStep = value
        EnableMicTip.activeStep = value
    }
}

// MARK: - Tips

struct TapDotTip: Tip {
    static var activeStep: Int = -1
    @Parameter static var step: Int = -1

    var title: Text { Text("Tap a Dot") }
    var message: Text? { Text("Quick taps create dots") }
    var image: Image? { Image(systemName: "circle") }
    var actions: [Action] { [Action(id: "next", title: "Next")] }
    var rules: [Rule] { #Rule(Self.$step) { $0 == OnboardingStep.tapDot.rawValue } }
}

struct TapDashTip: Tip {
    static var activeStep: Int = -1
    @Parameter static var step: Int = -1

    var title: Text { Text("Tap a Dash") }
    var message: Text? { Text("Hold a bit longer for dashes") }
    var image: Image? { Image(systemName: "minus") }
    var actions: [Action] { [Action(id: "next", title: "Next")] }
    var rules: [Rule] { #Rule(Self.$step) { $0 == OnboardingStep.tapDash.rawValue } }
}

struct AddSpaceTip: Tip {
    static var activeStep: Int = -1
    @Parameter static var step: Int = -1

    var title: Text { Text("Add a Space") }
    var message: Text? { Text("Swipe right to insert a gap") }
    var image: Image? { Image(systemName: "arrow.right") }
    var actions: [Action] { [Action(id: "next", title: "Next")] }
    var rules: [Rule] { #Rule(Self.$step) { $0 == OnboardingStep.addSpace.rawValue } }
}

struct SendDecodeTip: Tip {
    static var activeStep: Int = -1
    @Parameter static var step: Int = -1

    var title: Text { Text("Send & Decode") }
    var message: Text? { Text("Swipe up to decode your Morse input") }
    var image: Image? { Image(systemName: "arrow.up") }
    var actions: [Action] { [Action(id: "next", title: "Next")] }
    var rules: [Rule] { #Rule(Self.$step) { $0 == OnboardingStep.sendDecode.rawValue } }
}

struct EnableMicTip: Tip {
    static var activeStep: Int = -1
    @Parameter static var step: Int = -1

    var title: Text { Text("Enable Mic") }
    var message: Text? { Text("Long press anywhere to speak") }
    var image: Image? { Image(systemName: "mic") }
    var actions: [Action] { [Action(id: "next", title: "Finish")] }
    var rules: [Rule] { #Rule(Self.$step) { $0 == OnboardingStep.enableMic.rawValue } }
}

