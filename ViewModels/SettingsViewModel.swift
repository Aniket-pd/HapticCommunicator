import Foundation

class SettingsViewModel: ObservableObject {
    @Published var selectedSpeed: HapticSpeed = .standard
}
