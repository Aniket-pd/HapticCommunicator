import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel

    var body: some View {
        Form {
            Section(header: Text("Haptic Speed")) {
                Picker("Speed", selection: $settings.selectedSpeed) {
                    ForEach(HapticSpeed.allCases) { speed in
                        Text(speed.displayName).tag(speed)
                    }
                }
                .pickerStyle(.inline)
            }
            Section(header: Text("Audio")) {
                Toggle("Beep Sound", isOn: $settings.beepSoundEnabled)
                Toggle("Speech Sound", isOn: $settings.speechSoundEnabled)
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsViewModel())
    }
}
