import SwiftUI
import Instructions

/// Manages the onboarding tutorial using the Instructions library.
/// The tutorial highlights key areas of the app and is started from
/// `HomeView` when needed.
final class TutorialManager: NSObject, ObservableObject {
    private let coachMarksController = CoachMarksController()

    /// Frames of UI elements captured from SwiftUI views.
    var frames: [String: CGRect] = [:]

    /// Binding to the current selected tab so the tutorial can switch
    /// between screens.
    var selectedTab: Binding<TopTab>?

    /// Called when the tutorial finishes.
    var onFinish: (() -> Void)?

    override init() {
        super.init()
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.isUserInteractionEnabled = true
    }

    /// Starts the tutorial from the given root controller.
    func start(from controller: UIViewController,
               frames: [String: CGRect],
               selectedTab: Binding<TopTab>) {
        guard !coachMarksController.isStarted else { return }
        self.frames = frames
        self.selectedTab = selectedTab
        coachMarksController.start(in: .window(over: controller))
    }
}

private enum TutorialStep: Int, CaseIterable {
    case welcome
    case topTabs
    case userTapArea
    case messageHistory
    case caregiverField
    case settings
    case finish

    var text: String {
        switch self {
        case .welcome:
            return "The app lets you communicate using Morse code with haptics and speech."
        case .topTabs:
            return "Use these tabs to switch between User mode, Caregiver mode and Settings."
        case .userTapArea:
            return "Tap quickly for a dot, hold for a dash, swipe right for a space and swipe up to decode. Long‑press anywhere for speech input."
        case .messageHistory:
            return "Decoded text and Morse history appear here."
        case .caregiverField:
            return "Type text here, convert it to Morse and hand the device to the user."
        case .settings:
            return "Change haptic speed or toggle sounds. You can replay this walkthrough from here."
        case .finish:
            return "Walkthrough complete! You're ready to start using the app."
        }
    }
}

extension TutorialManager: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        TutorialStep.allCases.count
    }

    func coachMarksController(_ controller: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let step = TutorialStep.allCases[index]
        switch step {
        case .welcome:
            return controller.helper.makeCoachMark()
        case .topTabs:
            let frame = frames["topTabBar"] ?? .zero
            return controller.helper.makeCoachMark(for: nil,
                pointOfInterest: CGPoint(x: frame.midX, y: frame.midY)) { _ in
                UIBezierPath(roundedRect: frame, cornerRadius: 8)
            }
        case .userTapArea:
            let frame = frames["userTapArea"] ?? .zero
            return controller.helper.makeCoachMark(for: nil,
                pointOfInterest: CGPoint(x: frame.midX, y: frame.midY)) { _ in
                UIBezierPath(roundedRect: frame, cornerRadius: 8)
            }
        case .messageHistory:
            let frame = frames["messageHistory"] ?? .zero
            return controller.helper.makeCoachMark(for: nil,
                pointOfInterest: CGPoint(x: frame.midX, y: frame.midY)) { _ in
                UIBezierPath(roundedRect: frame, cornerRadius: 8)
            }
        case .caregiverField:
            let frame = frames["caregiverField"] ?? .zero
            return controller.helper.makeCoachMark(for: nil,
                pointOfInterest: CGPoint(x: frame.midX, y: frame.midY)) { _ in
                UIBezierPath(roundedRect: frame, cornerRadius: 8)
            }
        case .settings:
            let frame = frames["settings"] ?? .zero
            return controller.helper.makeCoachMark(for: nil,
                pointOfInterest: CGPoint(x: frame.midX, y: frame.midY)) { _ in
                UIBezierPath(roundedRect: frame, cornerRadius: 8)
            }
        case .finish:
            return controller.helper.makeCoachMark()
        }
    }

    func coachMarksController(_ controller: CoachMarksController,
                              coachMarkViewsAt index: Int,
                              madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let body = CoachMarkPlainBodyView()
        body.hintLabel.text = TutorialStep.allCases[index].text
        body.nextLabel.text = "Next"
        return (body, nil)
    }

    func coachMarksController(_ controller: CoachMarksController,
                              didShow coachMark: CoachMark,
                              afterChanging change: ConfigurationChange,
                              at index: Int) {
        let step = TutorialStep.allCases[index]
        switch step {
        case .caregiverField:
            selectedTab?.wrappedValue = .careTaker
        case .settings:
            selectedTab?.wrappedValue = .settings
        default:
            break
        }
    }

    func coachMarksController(_ controller: CoachMarksController,
                              didFinishShowingAndWasSkipped skipped: Bool) {
        onFinish?()
    }
}

