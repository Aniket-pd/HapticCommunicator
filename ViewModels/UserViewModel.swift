//
//  UserViewModel.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Handles tap input, builds Morse string, decodes to text, plays audio feedback.

import Foundation
import AVFoundation
import CoreHaptics
import Combine
import UIKit

class UserViewModel: ObservableObject {
    @Published var morseInput: String = ""
    @Published var decodedText: String = ""
    @Published var audioFeedbackEnabled: Bool = true

    private var speechSynthesizer = AVSpeechSynthesizer()
    private var hapticEngine: CHHapticEngine?
    private var tapStartTime: Date?
    private var recentDurations: [TimeInterval] = []
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var lastTapEndTime: Date?

    init() {
        prepareHaptics()
    }

    func handleTapStart() {
        let now = Date()
        if let lastEnd = lastTapEndTime {
            let gap = now.timeIntervalSince(lastEnd)
            if gap >= 1.0 {
                morseInput.append(" ")   // space between words
                playAudioFeedback("space")
            } else if gap >= 0.5 {
                morseInput.append("|")   // separator between letters
            }
        }
        tapStartTime = now
        startContinuousHaptic()
    }

    func handleTapEnd() {
        guard let startTime = tapStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        tapStartTime = nil
        stopContinuousHaptic()
        
        recentDurations.append(duration)
        if recentDurations.count > 10 {
            recentDurations.removeFirst()
        }

        let minDur = recentDurations.min() ?? 0
        let maxDur = recentDurations.max() ?? 1
        let threshold = (minDur + maxDur) / 2

        if duration < threshold {
            morseInput.append("·")
            playDotHaptic()  // short sharp haptic for dot
            playAudioFeedback("dot")
        } else {
            morseInput.append("−")
           
            playAudioFeedback("dash")
        }
        lastTapEndTime = Date()
    }

    func handleDoubleTap() {
        stopContinuousHaptic()  // Ensure no leftover vibration
        playSendHaptic()        // Play confirmation haptic

        let converter = MorseCodeConverter()
        decodedText = converter.morseToText(morseInput)
        playAudioFeedback("message sent")
        morseInput = ""
    }

    private func playAudioFeedback(_ text: String) {
        guard audioFeedbackEnabled else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    private func prepareHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }

    // private func playHaptic(type: UIImpactFeedbackGenerator.FeedbackStyle) {
    //     let generator = UIImpactFeedbackGenerator(style: type)
    //     generator.prepare()
    //     generator.impactOccurred()
    // }

    private func startContinuousHaptic() {
        guard let hapticEngine = hapticEngine else { return }
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 10.0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            continuousPlayer = try hapticEngine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: 0)
        } catch {
            print("Failed to start continuous haptic: \(error.localizedDescription)")
        }
    }

    private func stopContinuousHaptic() {
        do {
            try continuousPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stop continuous haptic: \(error.localizedDescription)")
        }
    }

    func reset() {
        morseInput = ""
        decodedText = ""
    }

    func toggleAudioFeedback() {
        audioFeedbackEnabled.toggle()
    }
}


    private func playSendHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func playDotHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    
