import Foundation
import CoreHaptics
import Combine

/// View model backing `SettingsView`. Stores the currently selected
/// `HapticSpeed` and provides a short haptic preview when the speed
/// changes.
class SettingsViewModel: ObservableObject {
    private static let selectedSpeedKey = "selectedSpeed"
    private static let beepSoundEnabledKey = "beepSoundEnabled"
    private static let speechSoundEnabledKey = "speechSoundEnabled"

    private let defaults: UserDefaults
    /// Currently selected haptic speed. `playSpeedPreview()` is called
    /// manually from `SettingsView` whenever this value changes.
    @Published var selectedSpeed: HapticSpeed {
        didSet { defaults.set(selectedSpeed.rawValue, forKey: Self.selectedSpeedKey) }
    }
    @Published var beepSoundEnabled: Bool {
        didSet { defaults.set(beepSoundEnabled, forKey: Self.beepSoundEnabledKey) }
    }
    @Published var speechSoundEnabled: Bool {
        didSet { defaults.set(speechSoundEnabled, forKey: Self.speechSoundEnabledKey) }
    }

    /// Haptic engine used for previewing speed changes.
    private var hapticEngine: CHHapticEngine?

    /// Currently running preview task so it can be cancelled when a new
    /// preview starts.
    private var previewTask: Task<Void, Never>? = nil

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let savedSpeed = defaults.string(forKey: Self.selectedSpeedKey),
           let speed = HapticSpeed(rawValue: savedSpeed) {
            self.selectedSpeed = speed
        } else {
            self.selectedSpeed = .standard
        }
        self.beepSoundEnabled = defaults.object(forKey: Self.beepSoundEnabledKey) as? Bool ?? true
        self.speechSoundEnabled = defaults.object(forKey: Self.speechSoundEnabledKey) as? Bool ?? true

        prepareHaptics()
    }

    /// Call when the settings view becomes visible.
    func startHapticEngine() {
        prepareHaptics()
    }

    /// Cancel any ongoing previews and stop the haptic engine.
    func stopHapticEngine() {
        previewTask?.cancel()
        previewTask = nil
        hapticEngine?.stop(completionHandler: nil)
    }

    /// Plays a short haptic preview of "This is your current speed" using the
    /// selected speed so the user immediately feels the effect.
    func playSpeedPreview() {
        // Cancel any currently running preview so haptics do not overlap
        previewTask?.cancel()
        previewTask = nil

        // Stop any haptic currently playing and restart the engine
        hapticEngine?.stop(completionHandler: nil)
        prepareHaptics()

        let morse = MorseCodeConverter().textToMorse("This is your current speed")
        previewTask = Task { await vibrate(morse: morse, speed: selectedSpeed) }
    }

    // MARK: - Private helpers

    /// Vibrates a Morse string once with the given speed.
    private func vibrate(morse: String, speed: HapticSpeed) async {
        guard let hapticEngine else { return }
        let unit = speed.unitDuration

        do {
            for symbol in morse {
                if Task.isCancelled {
                    hapticEngine.stop(completionHandler: nil)
                    return
                }
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
            if (error as? CancellationError) == nil {
                print("Haptic preview error: \(error.localizedDescription)")
            }
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
