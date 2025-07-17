import UIKit

/// Represents a single step in the in-app tutorial.
struct TutorialStep {
    /// The view that should be highlighted for this step.
    weak var targetView: UIView?
    /// Instructional text describing the highlighted item.
    let message: String
}

/// Overlay view that darkens the screen and highlights one area.
final class TutorialOverlayView: UIView {
    private let maskLayer = CAShapeLayer()
    private let instructionLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    var highlightFrame: CGRect = .zero { didSet { setNeedsLayout() } }

    /// Closure called when the user advances to the next step.
    var onNext: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)

        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer

        instructionLabel.textColor = .white
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instructionLabel)

        nextButton.setTitle("Next", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        addSubview(nextButton)

        NSLayoutConstraint.activate([
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            instructionLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -12),
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    @objc private func nextTapped() {
        onNext?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(rect: bounds)
        let circlePath = UIBezierPath(ovalIn: highlightFrame.insetBy(dx: -8, dy: -8))
        path.append(circlePath)
        maskLayer.path = path.cgPath
    }

    /// Updates the text displayed on screen.
    func updateMessage(_ text: String) {
        instructionLabel.text = text
    }
}

/// Manages the tutorial flow and persistence.
final class TutorialManager {
    private let steps: [TutorialStep]
    private let overlay = TutorialOverlayView()
    private var index = 0
    private weak var containerView: UIView?

    init(steps: [TutorialStep]) {
        self.steps = steps
        overlay.onNext = { [weak self] in self?.advance() }
        let tap = UITapGestureRecognizer(target: self, action: #selector(advance))
        overlay.addGestureRecognizer(tap)
    }

    /// Start the tutorial inside the given view if it hasn't been shown yet.
    func startIfNeeded(in view: UIView) {
        guard !UserDefaults.standard.bool(forKey: "didShowTutorial") else { return }
        containerView = view
        index = 0
        showStep()
        view.addSubview(overlay)
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    @objc private func advance() {
        index += 1
        if index < steps.count {
            showStep()
        } else {
            finish()
        }
    }

    private func showStep() {
        guard index < steps.count, let target = steps[index].targetView, let container = containerView else { return }
        let frame = target.convert(target.bounds, to: container)
        overlay.highlightFrame = frame
        overlay.updateMessage(steps[index].message)
    }

    private func finish() {
        overlay.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "didShowTutorial")
    }
}

