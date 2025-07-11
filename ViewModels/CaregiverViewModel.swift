//
//  CaregiverViewModel.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Handles input text, converts to Morse, triggers vibration.


import Foundation
import Combine
import CoreHaptics

class CaregiverViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var morseCode: String = ""
    @Published var isReadyForHandover: Bool = false
    @Published var errorMessage: String?

    private var hapticEngine: CHHapticEngine?

    init() {
        prepareHaptics()
    }

    func convertTextToMorse() {
        let converter = MorseCodeConverter()
        let morse = converter.textToMorse(inputText)
        if morse.isEmpty {
            errorMessage = "Unable to convert text to Morse code."
        } else {
            morseCode = morse
            isReadyForHandover = true
        }
    }

    func startVibration() {
        guard !morseCode.isEmpty else {
            errorMessage = "No Morse code to vibrate."
            return
        }
        vibrateMorseCode(morseCode)
    }

    private func prepareHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            errorMessage = "Haptics not supported on this device."
        }
    }

    private func vibrateMorseCode(_ morse: String) {
        var events = [CHHapticEvent]()
        var time: TimeInterval = 0

        for symbol in morse {
            switch symbol {
            case "·":
                events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: time, duration: 0.1))
                time += 0.2
            case "−":
                events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: time, duration: 0.3))
                time += 0.4
            case " ":
                time += 0.6 // longer pause between words
            default:
                continue
            }
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            errorMessage = "Failed to play haptic pattern."
        }
    }

    func reset() {
        inputText = ""
        morseCode = ""
        isReadyForHandover = false
        errorMessage = nil
    }
}
