import Foundation
import CoreHaptics

class LearnMorseCodeViewModel: ObservableObject {
    @Published var activeLetter: Character? = nil
    @Published var currentSymbolIndex: Int? = nil

    private var hapticEngine: CHHapticEngine?
    private var playTask: Task<Void, Never>?

    init() {
        prepareHaptics()
    }

    func startHapticEngine() {
        prepareHaptics()
    }

    func stopHapticEngine() {
        playTask?.cancel()
        playTask = nil
        hapticEngine?.stop(completionHandler: nil)
        activeLetter = nil
        currentSymbolIndex = nil
    }

    func play(morse: String, for letter: Character, speed: HapticSpeed) {
        playTask?.cancel()
        playTask = Task { await vibrate(morse: morse, for: letter, speed: speed) }
    }

    private func vibrate(morse: String, for letter: Character, speed: HapticSpeed) async {
        guard let hapticEngine else { return }
        let unit = speed.unitDuration
        await MainActor.run {
            self.activeLetter = letter
            self.currentSymbolIndex = nil
        }
        do {
            for (index, symbol) in morse.enumerated() {
                if Task.isCancelled {
                    hapticEngine.stop(completionHandler: nil)
                    return
                }
                await MainActor.run { self.currentSymbolIndex = index }
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
                print("Haptic play error: \(error.localizedDescription)")
            }
        }
        await MainActor.run {
            self.currentSymbolIndex = nil
            self.activeLetter = nil
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
