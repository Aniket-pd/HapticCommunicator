import Foundation
import CoreHaptics
import UIKit

/// Plays the "intro_haptics" AHAP file bundled in Assets.xcassets.
/// Used for a short welcome vibration when the app becomes active.
final class IntroHapticsPlayer {
    static let shared = IntroHapticsPlayer()
    private var engine: CHHapticEngine?

    private init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Intro haptic engine error: \(error.localizedDescription)")
        }
    }

    /// Plays the intro haptic sequence once.
    func play() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        guard let data = NSDataAsset(name: "intro_haptics")?.data else {
            print("Intro haptics asset not found")
            return
        }
        do {
            try engine?.start()
            let pattern = try CHHapticPattern(data: data)
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play intro haptics: \(error.localizedDescription)")
        }
    }
}
