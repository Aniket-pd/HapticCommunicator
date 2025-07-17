import SwiftUI

/// Invisible overlay that detects two-finger taps and calls `action`.
struct TwoFingerTapView: UIViewRepresentable {
    var action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: context.coordinator,
                                          action: #selector(Coordinator.tapped))
        tap.numberOfTouchesRequired = 2
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class Coordinator: NSObject {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }
        @objc func tapped() { action() }
    }
}
