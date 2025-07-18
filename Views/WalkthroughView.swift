import SwiftUI

/// Steps shown in the onboarding walkthrough.
enum WalkthroughStep: Int, CaseIterable {
    case welcome, topBar, userGestures, caregiver, settings, done
}

/// Simple overlay guiding the user through the app.
struct WalkthroughView: View {
    @Binding var step: WalkthroughStep
    var advance: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                Text(message(for: step))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                Button(step == .settings ? "Finish" : "Next") {
                    advance()
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
    }

    private func message(for step: WalkthroughStep) -> String {
        switch step {
        case .welcome:
            return "Welcome to HapticCommunicator! This walkthrough will show you the basics."
        case .topBar:
            return "Use the buttons at the top to switch between User, Caregiver and Settings modes."
        case .userGestures:
            return "In User mode: tap for dots and dashes, swipe right for a space, swipe up to send, and hold to speak."
        case .caregiver:
            return "In Caregiver mode, type text and tap 'Convert to Morse Code', then hand the device to the user."
        case .settings:
            return "Visit Settings to adjust haptic speed and toggle beep or speech sounds. You can restart this walkthrough here later."
        case .done:
            return ""
        }
    }
}

struct WalkthroughView_Previews: PreviewProvider {
    static var previews: some View {
        WalkthroughView(step: .constant(.welcome)) {}
    }
}
