import Foundation

class SettingsViewModel: ObservableObject {
    @Published var selectedSpeed: HapticSpeed = .standard
    @Published var beepSoundEnabled: Bool = true
    @Published var speechSoundEnabled: Bool = true
}
