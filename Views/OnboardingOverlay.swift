import SwiftUI
import TipKit

/// Semi-transparent overlay with gesture animation and a TipKit view.
struct OnboardingOverlay: View {
    @EnvironmentObject var manager: OnboardingManager

    var body: some View {
        if let tip = manager.currentTip {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { manager.advance() }

                VStack(spacing: 30) {
                    GestureAnimation(step: manager.stepIndex ?? 0)
                    TipView(tip, arrowEdge: .top)
                    Button("Next") { manager.advance() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .animation(.easeInOut, value: manager.stepIndex)
        }
    }
}

/// Simple animations for each tutorial step.
struct GestureAnimation: View {
    let step: Int
    @State private var animate = false

    var body: some View {
        let imageName: String
        switch step {
        case 0: imageName = "hand.tap"
        case 1: imageName = "hand.tap"
        case 2: imageName = "arrow.right"
        case 3: imageName = "arrow.up"
        default: imageName = "mic"
        }

        return Image(systemName: imageName)
            .font(.system(size: 60))
            .foregroundColor(.white)
            .scaleEffect(animate ? 1.2 : 1.0)
            .offset(x: step == 2 ? (animate ? 20 : -20) : 0,
                    y: step == 3 ? (animate ? -20 : 20) : 0)
            .onAppear { animate = true }
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animate)
    }
}

