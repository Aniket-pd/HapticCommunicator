import SwiftUI
import TipKit

// MARK: - Onboarding Steps
/// Represents each tutorial step presented to the user.
enum OnboardingStep: Int, CaseIterable {
    case tapDot
    case tapDash
    case addSpace
    case send
    case mic
}

/// Persistent state used to determine if onboarding was already shown
/// and to track the currently visible step.
class OnboardingState: ObservableObject {
    @AppStorage("hasSeenTutorial") var hasSeenTutorial: Bool = false
    @Published var step: OnboardingStep = .tapDot

    /// Advance to the next tutorial step or mark onboarding finished.
    func next() {
        if let next = OnboardingStep(rawValue: step.rawValue + 1) {
            step = next
        } else {
            hasSeenTutorial = true
        }
    }
}

// MARK: - Tutorial Tips
struct TapDotTip: Tip {
    var title: Text? { Text("Tap a Dot") }
    var message: Text? { Text("Single tap quickly to add a dot to your message.") }
}

struct TapDashTip: Tip {
    var title: Text? { Text("Tap a Dash") }
    var message: Text? { Text("Hold a little longer to enter a dash.") }
}

struct AddSpaceTip: Tip {
    var title: Text? { Text("Add a Space") }
    var message: Text? { Text("Swipe right to insert a space between letters.") }
}

struct SendTip: Tip {
    var title: Text? { Text("Send / Decode") }
    var message: Text? { Text("Swipe up to convert your Morse code into text.") }
}

struct MicTip: Tip {
    var title: Text? { Text("Enable Microphone") }
    var message: Text? { Text("Long‑press anywhere to speak instead of tapping.") }
}

// MARK: - Anchors used for spotlight highlighting
struct OnboardingAnchors {
    static let tapArea = Tip.Anchor()
    static let micIcon = Tip.Anchor()
}

// MARK: - Simple gesture hint animations
private struct TapAnimation: View {
    @State private var scale = 1.0
    var body: some View {
        Circle()
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 60, height: 60)
            .scaleEffect(scale)
            .opacity(0.8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 0.7
                }
            }
    }
}

private struct SwipeRightAnimation: View {
    @State private var offset: CGFloat = -20
    var body: some View {
        Image(systemName: "arrow.right")
            .foregroundColor(.white)
            .offset(x: offset)
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever()) {
                    offset = 20
                }
            }
    }
}

private struct SwipeUpAnimation: View {
    @State private var offset: CGFloat = 20
    var body: some View {
        Image(systemName: "arrow.up")
            .foregroundColor(.white)
            .offset(y: offset)
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever()) {
                    offset = -20
                }
            }
    }
}

private struct HoldAnimation: View {
    @State private var scale = 0.5
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .frame(width: 80, height: 80)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 1).repeatForever(autoreverses: false)) {
                    scale = 1
                }
            }
    }
}

// MARK: - Overlay showing the current tutorial tip
struct OnboardingOverlay: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)

            // Render current step
            switch state.step {
            case .tapDot:
                TipView(TapDotTip(), arrowEdge: .bottom, spotlight: .visible, for: OnboardingAnchors.tapArea)
                    .onTapGesture { state.next() }
                TapAnimation()
            case .tapDash:
                TipView(TapDashTip(), arrowEdge: .bottom, spotlight: .visible, for: OnboardingAnchors.tapArea)
                    .onTapGesture { state.next() }
                HoldAnimation()
            case .addSpace:
                TipView(AddSpaceTip(), arrowEdge: .bottom, spotlight: .visible, for: OnboardingAnchors.tapArea)
                    .onTapGesture { state.next() }
                SwipeRightAnimation()
            case .send:
                TipView(SendTip(), arrowEdge: .bottom, spotlight: .visible, for: OnboardingAnchors.tapArea)
                    .onTapGesture { state.next() }
                SwipeUpAnimation()
            case .mic:
                TipView(MicTip(), arrowEdge: .top, spotlight: .visible, for: OnboardingAnchors.micIcon)
                    .onTapGesture { state.next() }
                HoldAnimation()
            }
        }
        .animation(.easeInOut, value: state.step)
    }
}

