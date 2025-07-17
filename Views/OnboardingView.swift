import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let steps: [String]
    let systemImage: String
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Switch Modes",
            steps: [
                "Launch the app. You'll see tabs labeled User, Caregiver and Settings at the top.",
                "Tap a tab name to move between these modes at any time.",
                "Follow the rest of this tutorial to see what each mode can do."
            ],
            systemImage: "rectangle.3.offgrid"),
        OnboardingPage(
            title: "User Mode",
            steps: [
                "With the User tab selected you will see a large tap area.",
                "Tap briefly for a dot and tap and hold a little longer for a dash.",
                "Swipe right to insert a gap between letters.",
                "Swipe up to convert the current Morse sequence to text.",
                "Try typing \"SOS\" then swipe up to decode it.",
                "Long press anywhere to play the vibration for your caregiver."
            ],
            systemImage: "hand.tap"),
        OnboardingPage(
            title: "Caregiver Mode",
            steps: [
                "Switch to the Caregiver tab.",
                "Type a short phrase such as HELLO in the text field.",
                "Tap Convert to Morse Code.",
                "Hand the device to the user when prompted.",
                "They can tap anywhere to feel the vibration pattern." 
            ],
            systemImage: "person.crop.circle.badge.checkmark"),
        OnboardingPage(
            title: "Settings",
            steps: [
                "Open the Settings tab.",
                "Adjust the haptic speed slider and tap Preview to feel the updated tempo.",
                "Use the toggles to enable or disable beep and speech sounds.",
                "Return to User or Caregiver mode from the tabs when ready."
            ],
            systemImage: "gearshape"),
        OnboardingPage(
            title: "Gestures",
            steps: [
                "Tap – input a dot or confirm a button.",
                "Long press – speak input in User mode.",
                "Swipe right – insert a letter gap while entering Morse.",
                "Swipe up – decode the Morse sequence to text."
            ],
            systemImage: "hand.draw"),
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
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(page.steps.enumerated()), id: \.offset) { stepIndex, step in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("\(stepIndex + 1).")
                                        .bold()
                                    Text(step)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
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


#Preview {
    OnboardingView(isPresented: .constant(true))
}
