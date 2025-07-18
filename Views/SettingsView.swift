import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("showWalkthrough") private var showWalkthrough: Bool = false

    private let demoText = "This is your current text"
    private var demoMorse: String { MorseCodeConverter().textToMorse(demoText) }

    var body: some View {
        NavigationStack {
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
                NavigationLink("Learn Morse Code") {
                    LearnMorseCodeView()
                        .environmentObject(settings)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    settings.stopHapticEngine()
                })
            }
            Section {
                Button("Show Walkthrough Again") {
                    showWalkthrough = true
                }
            }
            }
            .navigationTitle("Settings")
        }
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
    }
}
