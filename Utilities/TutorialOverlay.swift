import UIKit

/// Represents a single step in the onboarding tutorial.
struct TutorialStep {
    weak var targetView: UIView?
    let message: String
}

/// Simple overlay highlighting UI elements and showing instructions.
/// Advances through the provided steps when the user taps `Next` or the target.
final class TutorialOverlay: UIView {
    private let steps: [TutorialStep]
    private var currentIndex = 0
    private let maskLayer = CAShapeLayer()
    private let messageLabel = UILabel()
    private let nextButton = UIButton(type: .system)

    /// Initializes the overlay with an array of steps.
    init(steps: [TutorialStep]) {
        self.steps = steps
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        layer.mask = maskLayer

        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
        messageLabel.font = .preferredFont(forTextStyle: .body)
        addSubview(messageLabel)

        nextButton.setTitle("Next", for: .normal)
        nextButton.tintColor = .white
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        addSubview(nextButton)

        let tap = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Presents the overlay inside the given view.
    func present(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)
        showStep(at: 0)
    }

    private func showStep(at index: Int) {
        guard index < steps.count, let target = steps[index].targetView else {
            removeFromSuperview()
            UserDefaults.standard.set(true, forKey: "didShowTutorial")
            return
        }
        currentIndex = index
        // Convert target rect to overlay coordinates.
        let targetFrame = target.superview?.convert(target.frame, to: self) ?? target.frame
        // Create a path with a transparent circle around the target.
        let radius: CGFloat = max(targetFrame.width, targetFrame.height) / 2 + 8
        let center = CGPoint(x: targetFrame.midX, y: targetFrame.midY)
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd

        messageLabel.text = steps[index].message
        messageLabel.frame = CGRect(x: 20, y: targetFrame.maxY + 20, width: bounds.width - 40, height: 0)
        messageLabel.sizeToFit()

        nextButton.setTitle(index == steps.count - 1 ? "Done" : "Next", for: .normal)
        nextButton.frame = CGRect(x: bounds.midX - 40, y: messageLabel.frame.maxY + 16, width: 80, height: 44)
    }

    @objc private func nextTapped() {
        showStep(at: currentIndex + 1)
    }
}

/// Convenience manager that checks UserDefaults and presents the tutorial once.
final class TutorialManager {
    static let shared = TutorialManager()
    private init() {}

    func showTutorialIfNeeded(from viewController: UIViewController, steps: [TutorialStep]) {
        guard !UserDefaults.standard.bool(forKey: "didShowTutorial") else { return }
        let overlay = TutorialOverlay(steps: steps)
        overlay.present(in: viewController.view)
    }
}

// MARK: - Example with the Instructions library (Bonus)

/*
import Instructions

class WalkthroughController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    let coachMarksController = CoachMarksController()
    weak var button: UIButton?

    init(button: UIButton) {
        self.button = button
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
    }

    func start(on parent: UIViewController) {
        coachMarksController.start(in: .window(over: parent))
    }

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int { 1 }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        guard let button else { return coachMarksController.helper.makeCoachMark() }
        return coachMarksController.helper.makeCoachMark(for: button)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: UIView & CoachMarkBodyView, arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true)
        coachViews.bodyView.hintLabel.text = "Tap this button to begin"
        coachViews.bodyView.nextLabel.text = "OK"
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}
*/
