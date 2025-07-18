import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        TabView {
            VStack(spacing: 20) {
                Image(systemName: "waveform.path")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 80/255, green: 200/255, blue: 120/255, opacity: 1))
                Text("Welcome to HapticCommunicator")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("Communicate using Morse code through haptics and speech. Please allow speech recognition when prompted.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()

            VStack(spacing: 20) {
                Image(systemName: "rectangle.split.3x1.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 80)
                    .foregroundColor(.blue)
                Text("Navigation")
                    .font(.title)
                Text("Use the top tab bar to switch between User, Caregiver and Settings modes.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()

            VStack(alignment: .leading, spacing: 16) {
                Text("User Mode")
                    .font(.title)
                VStack(alignment: .leading, spacing: 8) {
                    Label("Tap quickly for a dot", systemImage: "hand.tap")
                    Label("Hold slightly longer for a dash", systemImage: "hand.point.up.left.fill")
                    Label("Swipe right for a letter gap", systemImage: "arrow.right")
                    Label("Swipe up to decode the sequence", systemImage: "arrow.up")
                    Label("Long‑press anywhere for speech input", systemImage: "mic.fill")
                }
            }
            .padding()

            VStack(spacing: 20) {
                Image(systemName: "text.bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 80)
                    .foregroundColor(.purple)
                Text("Message History")
                    .font(.title)
                Text("Decoded text and Morse history appear at the top of the User screen.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()

            VStack(alignment: .leading, spacing: 16) {
                Text("Caregiver Mode")
                    .font(.title)
                VStack(alignment: .leading, spacing: 8) {
                    Label("Type text into the field", systemImage: "keyboard")
                    Label("Tap Convert to Morse Code", systemImage: "arrowtriangle.right.fill")
                    Label("Hand over the phone and tap to play the vibration", systemImage: "hand.tap")
                }
            }
            .padding()

            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.title)
                VStack(alignment: .leading, spacing: 8) {
                    Label("Choose your preferred haptic speed", systemImage: "speedometer")
                    Label("Toggle beep and speech sounds", systemImage: "speaker.wave.2.fill")
                    Label("Show Walkthrough Again", systemImage: "arrow.counterclockwise")
                }
                Button("Get Started") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 30)
            }
            .padding()
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
    }
}
