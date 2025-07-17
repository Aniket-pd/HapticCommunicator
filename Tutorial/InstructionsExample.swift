import UIKit
import Instructions // This requires the Instructions library from GitHub.

/// Example view controller using the third-party `Instructions` library.
/// Ensure you add `pod 'Instructions'` or the Swift Package before building.
final class InstructionsExampleVC: UIViewController, CoachMarksControllerDataSource {
    private let coachMarksController = CoachMarksController()
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        coachMarksController.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        coachMarksController.start(in: .window(over: self))
    }

    func numberOfCoachMarks(for controller: CoachMarksController) -> Int { 2 }

    func coachMarksController(_ controller: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let view = (index == 0) ? firstButton : secondButton
        return controller.helper.makeCoachMark(for: view)
    }

    func coachMarksController(_ controller: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.hintLabel.text = index == 0 ? "Tap here to start" : "Then tap here"
        coachViews.bodyView.nextLabel.text = "Ok"
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}
