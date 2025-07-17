import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let text: String
    let systemImage: String
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Switch Modes",
            text: "Use the top tabs to move between User Modes, Caregiver and Settings.",
            systemImage: "rectangle.3.offgrid"),
        OnboardingPage(
            title: "User Mode",
            text: "Tap for dots and dashes, swipe up to decode and long press to speak.",
            systemImage: "hand.tap"),
        OnboardingPage(
            title: "Caregiver Mode",
            text: "Type words then tap Convert to Morse Code. Hand the device to the user and tap anywhere to play it.",
            systemImage: "person.crop.circle.badge.checkmark"),
        OnboardingPage(
            title: "Settings",
            text: "Change the haptic speed, preview it and toggle beep or speech sounds.",
            systemImage: "gearshape"),
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 20) {
                        Image(systemName: page.systemImage)
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        Text(page.title)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(page.text)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .tag(index)
                    .padding()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

            Button(action: {
                if currentIndex < pages.count - 1 {
                    withAnimation { currentIndex += 1 }
                } else {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    isPresented = false
                }
            }) {
                Text(currentIndex == pages.count - 1 ? "Get Started" : "Next")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

