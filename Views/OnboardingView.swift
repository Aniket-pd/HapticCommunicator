import SwiftUI
import CoreHaptics

/// Displays a short walkthrough the very first time the app launches.
/// The user can swipe through the pages and try basic haptic gestures.
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var pageIndex = 0

    var body: some View {
        VStack {
            TabView(selection: $pageIndex) {
                OnboardingPage(
                    title: "Welcome",
                    description: "HapticCommunicator lets you chat using Morse code vibrations generated from taps or speech.",
                    demo: nil
                )
                .tag(0)

                OnboardingPage(
                    title: "Try tapping",
                    description: "Tap quickly for a dot and hold for a dash in the area below.",
                    demo: AnyView(DotDashDemoView())
                )
                .tag(1)

                OnboardingPage(
                    title: "Caregiver",
                    description: "Use the Caregiver tab to type a phrase and hand the phone to the user so they can feel it vibrate. Adjust speed in Settings.",
                    demo: nil
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(pageIndex == 2 ? "Get Started" : "Next") {
                if pageIndex < 2 {
                    withAnimation { pageIndex += 1 }
                } else {
                    hasCompletedOnboarding = true
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

private struct OnboardingPage: View {
    let title: String
    let description: String
    let demo: AnyView?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if let demo = demo {
                demo
            }
            Spacer()
        }
        .padding()
    }
}

/// Simple area that demonstrates dot and dash haptics.
private struct DotDashDemoView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.blue.opacity(0.2))
            .frame(width: 200, height: 200)
            .overlay(
                Text("Tap for Dot\nHold for Dash")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            )
            .highPriorityGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        let generator = UIImpactFeedbackGenerator(style: .rigid)
                        generator.impactOccurred()
                    }
            )
    }
}
