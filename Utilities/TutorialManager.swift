//
//  TutorialManager.swift
//  HapticCommunicator
//
//  Created by Codex on 11/20/23.
//  Handles a simple in-app walkthrough using UIKit overlays.
//

import UIKit

/// Describes a single tutorial step containing the target view and text to display.
struct TutorialStep {
    let targetView: UIView
    let message: String
}

/// Delegate to notify when the overlay is tapped or the next button is pressed.
protocol TutorialOverlayDelegate: AnyObject {
    func didRequestNextStep()
}

/// Semi-transparent overlay with a cut-out spotlight around a view.
/// Displays instructional text and a "Next" button.
final class TutorialOverlayView: UIView {

    weak var delegate: TutorialOverlayDelegate?

    private let messageLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private var maskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)

        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        nextButton.setTitle("Next", for: .normal)
        nextButton.tintColor = .white
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)

        addSubview(messageLabel)
        addSubview(nextButton)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNext))
        addGestureRecognizer(tapGesture)
    }

    /// Updates the spotlight area and message for the step.
    func configure(with step: TutorialStep, in container: UIView) {
        let targetFrame = step.targetView.convert(step.targetView.bounds, to: container)
        messageLabel.text = step.message

        // Spotlight path with a hole around the target view.
        let path = UIBezierPath(rect: bounds)
        let highlightPath = UIBezierPath(roundedRect: targetFrame.insetBy(dx: -8, dy: -8), cornerRadius: 8)
        path.append(highlightPath)
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer

        // Place the text below the highlighted view when possible.
        let labelWidth: CGFloat = bounds.width - 40
        let labelSize = messageLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
        let maxY = targetFrame.maxY + 16
        var labelY = maxY
        if maxY + labelSize.height + 60 > bounds.height { // if not enough space below
            labelY = targetFrame.minY - labelSize.height - 60
        }
        messageLabel.frame = CGRect(x: 20, y: max(labelY, 20), width: labelWidth, height: labelSize.height)
        nextButton.frame = CGRect(x: (bounds.width - 80) / 2, y: messageLabel.frame.maxY + 12, width: 80, height: 40)
    }

    @objc private func handleNext() {
        delegate?.didRequestNextStep()
    }
}

/// Manages progression through tutorial steps and persistence with UserDefaults.
final class TutorialManager: NSObject {
    static let shared = TutorialManager()

    private let overlay = TutorialOverlayView(frame: UIScreen.main.bounds)
    private var steps: [TutorialStep] = []
    private var currentIndex = 0
    private let defaultsKey = "hasSeenTutorial"

    var hasSeenTutorial: Bool {
        UserDefaults.standard.bool(forKey: defaultsKey)
    }

    private override init() {
        super.init()
        overlay.delegate = self
    }

    /// Begins showing the tutorial over the provided window.
    func startTutorial(with steps: [TutorialStep], in window: UIWindow) {
        guard !hasSeenTutorial, !steps.isEmpty else { return }
        self.steps = steps
        currentIndex = 0
        overlay.frame = window.bounds
        window.addSubview(overlay)
        showCurrentStep()
    }

    private func showCurrentStep() {
        guard currentIndex < steps.count, let window = overlay.superview else {
            finishTutorial()
            return
        }
        let step = steps[currentIndex]
        overlay.configure(with: step, in: window)
    }

    private func finishTutorial() {
        overlay.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: defaultsKey)
    }
}

extension TutorialManager: TutorialOverlayDelegate {
    func didRequestNextStep() {
        currentIndex += 1
        showCurrentStep()
    }
}

// MARK: - Example Usage with the Instructions library

/*
import Instructions

class InstructionsExampleViewController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    let coachMarksController = CoachMarksController()

    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var myLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: "hasSeenCoachMarks") {
            coachMarksController.start(in: .window(over: self))
        }
    }

    // MARK: Instructions Data Source
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0: return coachMarksController.helper.makeCoachMark(for: myButton)
        case 1: return coachMarksController.helper.makeCoachMark(for: myLabel)
        default: return coachMarksController.helper.makeCoachMark()
        }
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let views = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        views.bodyView.hintLabel.text = index == 0 ?
            "Press this button to begin sending vibration." :
            "This label shows the decoded text or status." 
        views.bodyView.nextLabel.text = "Next"
        return (bodyView: views.bodyView, arrowView: views.arrowView)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingAndWasSkipped skipped: Bool) {
        UserDefaults.standard.set(true, forKey: "hasSeenCoachMarks")
    }
}
*/
