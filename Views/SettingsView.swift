import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @EnvironmentObject var onboarding: OnboardingManager
    @Environment(\.scenePhase) private var scenePhase

    private let demoText = "This is your current text"
    private var demoMorse: String { MorseCodeConverter().textToMorse(demoText) }

    var body: some View {
        Form {
            Section(header: Text("Haptic Speed")) {
                Picker("Speed", selection: $settings.selectedSpeed) {
                    ForEach(HapticSpeed.allCases) { speed in
                        Text(speed.displayName).tag(speed)
                    }
                }
                .pickerStyle(.inline)
                .onChange(of: settings.selectedSpeed) { _ in
                    settings.playSpeedPreview()
                }
            }

            Section(header: Text("Demo")) {
                Text("\"\(demoText)\"")
                    .font(.headline)
                Text(demoMorse)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)
            }
            Section(header: Text("Audio")) {
                Toggle("Beep Sound", isOn: $settings.beepSoundEnabled)
                Toggle("Speech Sound", isOn: $settings.speechSoundEnabled)
            }

            Section {
                Button("Replay Onboarding") {
                    onboarding.replay()
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            settings.startHapticEngine()
        }
        .onDisappear {
            settings.stopHapticEngine()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                settings.startHapticEngine()
                SoundManager.shared.reactivate()
            } else if phase == .background {
                settings.stopHapticEngine()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsViewModel())
            .environmentObject(OnboardingManager())
    }
}
