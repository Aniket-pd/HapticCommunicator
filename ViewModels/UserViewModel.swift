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
import Speech

class UserViewModel: ObservableObject {
    private var silenceTimer: Timer?
    @Published var morseInput: String = ""
    @Published var decodedText: String = ""
    @Published var morseHistory: String = ""
    var settings: SettingsViewModel?

    private var speechSynthesizer = AVSpeechSynthesizer()
    private var hapticEngine: CHHapticEngine?
    private var tapStartTime: Date?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var breathingPlayer: CHHapticAdvancedPatternPlayer?
    private var lastTapEndTime: Date?
    private var audioEngine = AVAudioEngine()
    
    private let soundManager = SoundManager.shared

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var lastSpeechResultTime: Date?

    private let heavyImpactGenerator: UIImpactFeedbackGenerator
    private let rigidImpactGenerator: UIImpactFeedbackGenerator

    init() {
        self.heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        self.rigidImpactGenerator = UIImpactFeedbackGenerator(style: .rigid)
        self.heavyImpactGenerator.prepare()
        self.rigidImpactGenerator.prepare()
        prepareHaptics()
    }

    func handleTapStart() {
        tapStartTime = Date()
        startContinuousHaptic()
    }

    func handleTapEnd() {
        guard let startTime = tapStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        tapStartTime = nil
        stopContinuousHaptic()

        let threshold = 0.15  // hardcoded threshold between dot and dash

        if duration < threshold {
            morseInput.append("·")
            morseHistory.append("·")
            playDotHaptic()  // short sharp haptic for dot
            playDotBeep()
        } else {
            morseInput.append("−")
            morseHistory.append("−")
            playDashBeep()
        }
        lastTapEndTime = Date()
    }

    func playDotBeep() {
        guard settings?.beepSoundEnabled ?? true else { return }
        soundManager.dotPlayer?.currentTime = 0
        soundManager.dotPlayer?.play()
    }

    func playDashBeep() {
        guard settings?.beepSoundEnabled ?? true else { return }
        soundManager.dashPlayer?.currentTime = 0
        soundManager.dashPlayer?.play()
    }

    func handleDoubleTap() {
        stopContinuousHaptic()  // Ensure no leftover vibration
        playSendHaptic()        // Play confirmation haptic

        let converter = MorseCodeConverter()
        let decoded = converter.morseToText(morseInput)
        decodedText += decoded + " "
        morseHistory.append(" / ")
        playAudioFeedback(decoded)
        morseInput = ""
    }

    private func playAudioFeedback(_ text: String) {
        guard settings?.speechSoundEnabled ?? true else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()

            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 10.0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            continuousPlayer = try hapticEngine?.makeAdvancedPlayer(with: pattern)
        } catch {
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }
    

    /// Starts the haptic engine if needed. Call this when the view appears.
    func startHapticEngine() {
        prepareHaptics()
    }

    /// Stops any ongoing haptics and shuts down the engine.
    func stopHapticEngine() {
        stopContinuousHaptic()
        hapticEngine?.stop(completionHandler: nil)
    }

    // private func playHaptic(type: UIImpactFeedbackGenerator.FeedbackStyle) {
    //     let generator = UIImpactFeedbackGenerator(style: type)
    //     generator.prepare()
    //     generator.impactOccurred()
    // }

    private func startContinuousHaptic() {
        do {
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

    /// Cancels the current tap without registering a dot or dash.
    /// Stops the continuous haptic and clears the start time.
    func cancelTap() {
        tapStartTime = nil
        stopContinuousHaptic()
    }

    func startBreathingHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let hapticEngine = hapticEngine else { return }
        do {
            // The audio session configuration performed when starting speech
            // recognition can stop the haptic engine. Ensure the engine is
            // running before creating the breathing player.
            try hapticEngine.start()
            let inhale = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0,
                duration: 1.0)
            let exhale = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 1.0,
                duration: 1.0)
            let pattern = try CHHapticPattern(events: [inhale, exhale], parameters: [])
            breathingPlayer = try hapticEngine.makeAdvancedPlayer(with: pattern)
            breathingPlayer?.loopEnabled = true
            breathingPlayer?.loopEnd = 2.0
            try breathingPlayer?.start(atTime: 0)
        } catch {
            print("Failed to start breathing haptics: \(error.localizedDescription)")
        }
    }

    func stopBreathingHaptics() {
        do {
            try breathingPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stop breathing haptics: \(error.localizedDescription)")
        }
        breathingPlayer = nil
    }

    func playCloseHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let hapticEngine = hapticEngine else { return }
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play close haptic: \(error.localizedDescription)")
        }
    }

    func reset() {
        morseInput = ""
        decodedText = ""
    }

    func handleLetterGap() {
        stopContinuousHaptic()  // stop any ongoing continuous haptic
        morseInput.append(" ")  // separator between letters
        morseHistory.append(" ")
        rigidImpactGenerator.prepare()
        rigidImpactGenerator.impactOccurred()
    }
    
    func startListening(onResult: @escaping (String) -> Void, onTimeout: @escaping () -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                print("Speech recognition not authorized")
                return
            }
            print("Starting speech recognition...")
        }

        // Stop and remove previous tap if needed before setting up a new one
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                print("Received partial result: \(result.bestTranscription.formattedString)")
                self.lastSpeechResultTime = Date()
                DispatchQueue.main.async {
                    onResult(result.bestTranscription.formattedString)
                }
            }
            if error != nil || result?.isFinal == true {
                print("Speech recognition ended or error: \(String(describing: error))")
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                    mode: .measurement,
                                    options: [.defaultToSpeaker, .allowBluetooth])
            try session.setPreferredSampleRate(44_100)
            try session.setActive(true)
            try session.overrideOutputAudioPort(.speaker)
            print("Audio session configured for speech recognition")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine couldn't start: \(error.localizedDescription)")
        }

        silenceTimer?.invalidate()
        lastSpeechResultTime = Date()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if let lastTime = self.lastSpeechResultTime {
                let silenceDuration = Date().timeIntervalSince(lastTime)
                if silenceDuration >= 3 {
                    DispatchQueue.main.async {
                        timer.invalidate()
                        self.silenceTimer = nil
                        onTimeout()
                    }
                }
            }
        }
    }

    func stopListening() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        print("Stopping speech recognition...")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        audioEngine.reset()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("AVAudioSession deactivated")
        } catch {
            print("Failed to deactivate AVAudioSession: \(error.localizedDescription)")
        }
    }

    private func playDotHaptic() {
        heavyImpactGenerator.prepare()
        heavyImpactGenerator.impactOccurred()
    }
}


    private func playSendHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }



    
