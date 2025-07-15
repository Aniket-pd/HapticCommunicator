import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var selectedSpeed: HapticSpeed = .standard
}
