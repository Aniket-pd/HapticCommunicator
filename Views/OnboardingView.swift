import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let text: String
    let systemImage: String
    let demo: AnyView?

    init(title: String, text: String, systemImage: String, demo: AnyView? = nil) {
        self.title = title
        self.text = text
        self.systemImage = systemImage
        self.demo = demo
    }
}

// MARK: - Demo Views

private struct ModeSwitcherDemo: View {
    @State private var selection = 0

    var body: some View {
        Picker("Mode", selection: $selection) {
            Text("User").tag(0)
            Text("Caregiver").tag(1)
            Text("Settings").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

private struct UserModeDemo: View {
    @State private var morse: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text(morse.isEmpty ? "Tap below" : morse)
                .font(.system(.body, design: .monospaced))
            HStack(spacing: 20) {
                Button("•") { morse.append("•") }
                Button("–") { morse.append("–") }
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct CaregiverModeDemo: View {
    @State private var input: String = ""
    private var morse: String { MorseCodeConverter().textToMorse(input) }

    var body: some View {
        VStack(spacing: 12) {
            TextField("hello", text: $input)
                .textFieldStyle(.roundedBorder)
            Text(morse)
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

private struct SettingsDemo: View {
    @State private var speed: HapticSpeed = .normal

    var body: some View {
        Picker("Speed", selection: $speed) {
            ForEach(HapticSpeed.allCases) { speed in
                Text(speed.displayName).tag(speed)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Switch Modes",
            text: "Use the top tabs to move between User, Caregiver and Settings screens.",
            systemImage: "rectangle.3.offgrid",
            demo: AnyView(ModeSwitcherDemo())),
        OnboardingPage(
            title: "User Mode",
            text: "Tap for dots and dashes, swipe up to decode and long press to speak.",
            systemImage: "hand.tap",
            demo: AnyView(UserModeDemo())),
        OnboardingPage(
            title: "Caregiver Mode",
            text: "Type words then tap Convert to Morse Code. Hand the device to the user and tap anywhere to play it.",
            systemImage: "person.crop.circle.badge.checkmark",
            demo: AnyView(CaregiverModeDemo())),
        OnboardingPage(
            title: "Settings",
            text: "Change the haptic speed, preview it and toggle beep or speech sounds.",
            systemImage: "gearshape",
            demo: AnyView(SettingsDemo())),
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
                        if let demo = page.demo {
                            demo
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
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

