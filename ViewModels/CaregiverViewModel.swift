//
//  CaregiverViewModel.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Handles input text, converts to Morse, triggers vibration.


import Foundation
import Combine
import CoreHaptics
import UIKit
import AVFoundation

class CaregiverViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var morseCode: String = ""
    @Published var isReadyForHandover: Bool = false
    @Published var errorMessage: String?
    @Published var isVibrating: Bool = false
    @Published var currentSymbolIndex: Int? = nil

    private var hapticEngine: CHHapticEngine?
    private var dotPlayer: AVAudioPlayer?
    private var dashPlayer: AVAudioPlayer?

    init() {
        prepareHaptics()
        prepareBeepSounds()
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

    func startVibration(speed: HapticSpeed) async {
        guard !morseCode.isEmpty else {
            errorMessage = "No Morse code to vibrate."
            return
        }
        guard !isVibrating else {
            return
        }
        isVibrating = true

        let unit = speed.unitDuration
        do {
            for (index, symbol) in morseCode.enumerated() {
                await MainActor.run {
                    self.currentSymbolIndex = index
                }

                switch symbol {
                case "·":
                    dotPlayer?.currentTime = 0
                    dotPlayer?.play()
                    let event = CHHapticEvent(
                        eventType: .hapticTransient,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                        ],
                        relativeTime: 0)
                    let pattern = try CHHapticPattern(events: [event], parameters: [])
                    let player = try hapticEngine?.makePlayer(with: pattern)
                    try player?.start(atTime: 0)
                    try? await Task.sleep(nanoseconds: UInt64(unit * 1_000_000_000))

                case "−":
                    dashPlayer?.currentTime = 0
                    dashPlayer?.play()
                    let event = CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                        ],
                        relativeTime: 0,
                        duration: unit)
                    let pattern = try CHHapticPattern(events: [event], parameters: [])
                    let player = try hapticEngine?.makePlayer(with: pattern)
                    try player?.start(atTime: 0)
                    try? await Task.sleep(nanoseconds: UInt64(unit * 2 * 1_000_000_000))

                case " ":
                    try? await Task.sleep(nanoseconds: UInt64(unit * 2 * 1_000_000_000))

                default:
                    continue
                }
            }
        } catch {
            errorMessage = "Failed to play haptic pattern."
        }

        await MainActor.run {
            self.currentSymbolIndex = nil
        }

        isVibrating = false
    }

    private func prepareHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            errorMessage = "Haptics not supported on this device."
        }
    }

    private func prepareBeepSounds() {
        if let dotData = NSDataAsset(name: "dot")?.data,
           let dashData = NSDataAsset(name: "dash")?.data {
            do {
                dotPlayer = try AVAudioPlayer(data: dotData, fileTypeHint: "wav")
                dashPlayer = try AVAudioPlayer(data: dashData, fileTypeHint: "wav")
                dotPlayer?.prepareToPlay()
                dashPlayer?.prepareToPlay()
            } catch {
                errorMessage = "Failed to load beep sounds."
            }
        }
    }

    private func vibrateMorseCode(_ morse: String) {
        var events = [CHHapticEvent]()
        var time: TimeInterval = 0

        for symbol in morse {
            switch symbol {
            case "·":
                let dotEvent = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                    ],
                    relativeTime: time)
                events.append(dotEvent)
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

        if events.isEmpty {
            return
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
