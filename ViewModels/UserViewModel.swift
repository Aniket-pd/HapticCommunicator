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

    init() {
        prepareHaptics()
    }

    func handleTapStart() {
        tapStartTime = Date()
    }

    func handleTapEnd() {
        guard let startTime = tapStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        tapStartTime = nil

        // Save to recentDurations (keep max 10)
        recentDurations.append(duration)
        if recentDurations.count > 10 {
            recentDurations.removeFirst()
        }

        // Calculate dynamic threshold
        let minDur = recentDurations.min() ?? 0
        let maxDur = recentDurations.max() ?? 1
        let threshold = (minDur + maxDur) / 2

        // Determine dot or dash based on adaptive threshold
        if duration < threshold {
            morseInput.append("·")
            playHaptic(type: .light)
            playAudioFeedback("dot")
        } else {
            morseInput.append("−")
            playHaptic(type: .medium)
            playAudioFeedback("dash")
        }
    }

    func handleDoubleTap() {
        // Decode Morse to text
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

    private func playHaptic(type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.prepare()
        generator.impactOccurred()
    }

    func reset() {
        morseInput = ""
        decodedText = ""
    }

    func toggleAudioFeedback() {
        audioFeedbackEnabled.toggle()
    }
}

