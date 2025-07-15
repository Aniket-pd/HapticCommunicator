import Foundation
import CoreHaptics

/// View model backing `SettingsView`. Stores the currently selected
/// `HapticSpeed` and provides a short haptic preview when the speed
/// changes.
class SettingsViewModel: ObservableObject {
    /// Currently selected haptic speed. `playSpeedPreview()` is called
    /// manually from `SettingsView` whenever this value changes.
    @Published var selectedSpeed: HapticSpeed = .standard

    /// Haptic engine used for previewing speed changes.
    private var hapticEngine: CHHapticEngine?

    init() {
        prepareHaptics()
    }

    /// Plays a short haptic preview of "This is your current speed" using the
    /// selected speed so the user immediately feels the effect.
    func playSpeedPreview() {
        let morse = MorseCodeConverter().textToMorse("This is your current speed")
        Task { await vibrate(morse: morse, speed: selectedSpeed) }
    }

    // MARK: - Private helpers

    /// Vibrates a Morse string once with the given speed.
    private func vibrate(morse: String, speed: HapticSpeed) async {
        guard let hapticEngine else { return }
        let unit = speed.unitDuration

        do {
            for symbol in morse {
                switch symbol {
                case "·":
                    let event = CHHapticEvent(
                        eventType: .hapticTransient,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                        ],
                        relativeTime: 0)
                    let pattern = try CHHapticPattern(events: [event], parameters: [])
                    let player = try hapticEngine.makePlayer(with: pattern)
                    try player.start(atTime: 0)
                    try await Task.sleep(nanoseconds: UInt64(unit * 1_000_000_000))

                case "−":
                    let event = CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                        ],
                        relativeTime: 0,
                        duration: unit)
                    let pattern = try CHHapticPattern(events: [event], parameters: [])
                    let player = try hapticEngine.makePlayer(with: pattern)
                    try player.start(atTime: 0)
                    try await Task.sleep(nanoseconds: UInt64(unit * 2 * 1_000_000_000))

                case " ":
                    try await Task.sleep(nanoseconds: UInt64(unit * 2 * 1_000_000_000))

                default:
                    continue
                }
            }
        } catch {
            print("Haptic preview error: \(error.localizedDescription)")
        }
    }

    private func prepareHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }
}
