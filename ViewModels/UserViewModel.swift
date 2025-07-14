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
    @Published var morseInput: String = ""
    @Published var decodedText: String = ""
    @Published var audioFeedbackEnabled: Bool = true
    @Published var morseHistory: String = ""

    private var speechSynthesizer = AVSpeechSynthesizer()
    private var hapticEngine: CHHapticEngine?
    private var tapStartTime: Date?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var lastTapEndTime: Date?
    private var audioEngine = AVAudioEngine()

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    init() {
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
    private func playBeep(frequency: Double, duration: Double) {
        let sampleRate = 44100
        let frameCount = AVAudioFrameCount(duration * Double(sampleRate))
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let theta = 2.0 * Double.pi * frequency / Double(sampleRate)
        for i in 0..<Int(frameCount) {
            var sample = sin(theta * Double(i))
            let progress = Double(i) / Double(frameCount)
            let fadeInFactor = min(1.0, progress * 5.0)  // fade in over ~20% of duration
            let fadeOutFactor = 1.0 - progress           // fade out over entire duration
            sample *= fadeInFactor * fadeOutFactor
            buffer.floatChannelData!.pointee[i] = Float32(sample)
        }

        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)

        try? audioEngine.start()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: {
            DispatchQueue.main.async {
                playerNode.stop()
            }
        })
        playerNode.play()
    }

    func playDotBeep() {
        playBeep(frequency: 440, duration: 0.1)
    }

    func playDashBeep() {
        playBeep(frequency: 440, duration: 0.3)
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

    func handleLetterGap() {
        stopContinuousHaptic()  // stop any ongoing continuous haptic
        morseInput.append(" ")  // separator between letters
        morseHistory.append(" ")
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func startListening(onResult: @escaping (String) -> Void) {
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
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            try session.overrideOutputAudioPort(.speaker)
            print("Audio session set to playAndRecord with defaultToSpeaker and speaker override")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine couldn't start: \(error.localizedDescription)")
        }
    }

    func stopListening() {
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

    
