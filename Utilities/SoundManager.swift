import Foundation
import UIKit
import AVFoundation

/// Loads and provides audio players for dot and dash beep sounds.
/// Manages common beep sounds used across view models.
///
/// The players are loaded once on first access via the shared instance.
final class SoundManager {
    static let shared = SoundManager()

    /// Player used for the dot sound.
    let dotPlayer: AVAudioPlayer?

    /// Player used for the dash sound.
    let dashPlayer: AVAudioPlayer?

    private init() {
        var dot: AVAudioPlayer? = nil
        var dash: AVAudioPlayer? = nil

        if let dotData = NSDataAsset(name: "dot")?.data,
           let dashData = NSDataAsset(name: "dash")?.data {
            do {
                dot = try AVAudioPlayer(data: dotData, fileTypeHint: "wav")
                dash = try AVAudioPlayer(data: dashData, fileTypeHint: "wav")
                dot?.prepareToPlay()
                dash?.prepareToPlay()
            } catch {
                print("Audio setup failed: \(error.localizedDescription)")
            }
        } else {
            print("Audio assets 'dot' or 'dash' not found!")
        }

        self.dotPlayer = dot
        self.dashPlayer = dash
    }

    /// Prepares the audio players again after an interruption or when
    /// returning from the background to ensure sounds play reliably.
    func reactivate() {
        dotPlayer?.prepareToPlay()
        dashPlayer?.prepareToPlay()
    }
}
