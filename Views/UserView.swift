//
//  UserView.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Full-screen tap area, live input, decoded text, audio feedback toggle


import SwiftUI

struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
    @StateObject private var caregiverViewModel = CaregiverViewModel()
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPressing = false
    @State private var showHelloWorld = false
    @State private var breathing = false
    /// True when a long-press mic recording session is active. Used to ignore
    /// tap gestures until the finger is lifted.
    @State private var micRecording = false
    @State private var messageHistory: [Message] = [
        Message(text: "Decoded text will be displayed here", morse: "Morse code history will appear here", isSpeech: false)
    ]
    @State private var liveRecognizedText: String = ""
    @State private var liveMorseText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                // HStack {
                //     Spacer()
                //     Text(viewModel.decodedText.isEmpty ? "Decoded text will be displayed here" : viewModel.decodedText)
                //         .font(.system(size: 22, weight: .semibold))
                //         .foregroundColor(Color.primary)
                //         .multilineTextAlignment(.trailing)
                // }
                // .padding(.horizontal)

                // HStack {
                //     Spacer()
                //     Text(viewModel.morseHistory.isEmpty ? "Morse code history will appear here" : viewModel.morseHistory)
                //         .font(.system(size: 14, design: .monospaced))
                //         .foregroundColor(.gray)
                //         .multilineTextAlignment(.trailing)
                //         .lineLimit(nil)
                // }
                // .padding(.horizontal)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(messageHistory) { message in
                                VStack(alignment: message.isSpeech ? .leading : .trailing, spacing: 2) {
                                    HStack {
                                        if message.isSpeech {
                                            Text(message.text)
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(Color.primary)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        } else {
                                            Spacer()
                                            Text(message.text)
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(Color.primary)
                                                .multilineTextAlignment(.trailing)
                                        }
                                    }
                                    HStack {
                                        if message.isSpeech {
                                            if caregiverViewModel.isVibrating && caregiverViewModel.activeMessageID == message.id {
                                                AnimatedMorseView(morse: message.morse, currentIndex: caregiverViewModel.currentSymbolIndex)
                                                    .frame(height: 20)
                                            } else {
                                                Text(message.morse)
                                                    .font(.system(size: 14, design: .monospaced))
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            Spacer()
                                        } else {
                                            Spacer()
                                            Text(message.morse)
                                                .font(.system(size: 14, design: .monospaced))
                                                .foregroundColor(
                                                    message.morse == "Morse code history will appear here"
                                                    ? .gray
                                                    : Color(red: 80/255, green: 200/255, blue: 120/255, opacity: 1)
                                                )
                                                .multilineTextAlignment(.trailing)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: message.isSpeech ? .leading : .trailing)
                                .padding(.vertical, 8)
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 200) // Adjust this height to show ~2 message blocks
                    .onChange(of: messageHistory.count) { _ in
                        if let last = messageHistory.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                HStack {
                    Text(viewModel.morseInput)
                        .font(.system(size: 28, design: .monospaced))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .opacity(0.4)
                    Text("Hold anywhere to Listen\ntap anywhere ; swipe up to send ; swipe right for space")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.gray)
                        .opacity(0.4)
                }
                }
                .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressing && !micRecording {
                            isPressing = true

                            // Remove intro message if present
                            if let first = messageHistory.first, first.text == "Decoded text will be displayed here" {
                                messageHistory.removeFirst()
                            }

                            viewModel.handleTapStart()
                        }
                    }
                    .onEnded { value in
                        isPressing = false
                        if micRecording {
                            // Ignore gesture completions while recording
                            micRecording = false
                            return
                        }
                        if value.translation.height < -50 {
                            viewModel.handleDoubleTap()
                            if let lastIndex = messageHistory.indices.last {
                                if messageHistory[lastIndex].isSpeech {
                                    // Last was speech → create new decoded block
                                    messageHistory.append(Message(text: viewModel.decodedText, morse: viewModel.morseHistory, isSpeech: false))
                                } else {
                                    // Last was decoded → append new text/morse to existing decoded block
                                    let updatedText = messageHistory[lastIndex].text + viewModel.decodedText
                                    let updatedMorse = messageHistory[lastIndex].morse + " " + viewModel.morseHistory
                                    messageHistory[lastIndex] = Message(text: updatedText, morse: updatedMorse, isSpeech: false)
                                }
                            } else {
                                // No history → first decoded block
                                messageHistory.append(Message(text: viewModel.decodedText, morse: viewModel.morseHistory, isSpeech: false))
                            }
                            // Always clear live input after processing
                            viewModel.decodedText = ""
                            viewModel.morseHistory = ""
                        } else if value.translation.width > 50 {
                            // Swipe right → letter gap
                            viewModel.handleLetterGap()
                        } else {
                            // Normal tap end → dot or dash
                            viewModel.handleTapEnd()
                        }
                    }
            )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 2)
                        .onEnded { _ in
                            micRecording = true
                            viewModel.cancelTap()
                            withAnimation {
                                showHelloWorld = true
                            }
                            breathing = true
                            viewModel.startListening(
                                onResult: { text in
                                    let converter = MorseCodeConverter()
                                    let morse = converter.textToMorse(text)
                                    liveRecognizedText = text
                                    liveMorseText = morse
                                },
                                onTimeout: { [self] in
                                    withAnimation {
                                        showHelloWorld = false
                                    }
                                    Task {
                                        await viewModel.stopListening()
                                        if !liveRecognizedText.isEmpty {
                                            let newMessage = Message(text: liveRecognizedText, morse: liveMorseText, isSpeech: true)
                                            messageHistory.append(newMessage)

                                            caregiverViewModel.morseCode = liveMorseText
                                            caregiverViewModel.activeMessageID = newMessage.id
                                            await caregiverViewModel.startVibration(speed: settings.selectedSpeed)

                                            liveRecognizedText = ""
                                            liveMorseText = ""
                                        }
                                    }
                                }
                            )
                            viewModel.startBreathingHaptics()
                        }
                )
                .padding()

                if showHelloWorld {
                    Color.green
                        .ignoresSafeArea()
                        .overlay(
                            ZStack {
                                VStack {
                                    Text("I'm Listening")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(180))
                                        .padding(.top, 100)
                                    Spacer()
                                    Text("I'm Listening")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 100)
                                }
                                Circle()
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 180, height: 180)
                                    .scaleEffect(breathing ? 1.2 : 0.8)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: breathing)
                            }
                        )
                        .onDisappear {
                            breathing = false
                            viewModel.stopBreathingHaptics()
                        }
                        .onTapGesture {
                            micRecording = false
                            withAnimation {
                                showHelloWorld = false
                            }
                            viewModel.playCloseHaptic()
                            Task {
                                await viewModel.stopListening()
                                if !liveRecognizedText.isEmpty {
                                    let newMessage = Message(text: liveRecognizedText, morse: liveMorseText, isSpeech: true)
                                    messageHistory.append(newMessage)

                                    caregiverViewModel.morseCode = liveMorseText
                                    caregiverViewModel.activeMessageID = newMessage.id
                                    await caregiverViewModel.startVibration(speed: settings.selectedSpeed)

                                    liveRecognizedText = ""
                                    liveMorseText = ""
                                }
                            }
                        }
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.settings = settings
                caregiverViewModel.settings = settings
                viewModel.startHapticEngine()
                caregiverViewModel.startHapticEngine()
            }
            .onDisappear {
                viewModel.stopHapticEngine()
                caregiverViewModel.stopHapticEngine()
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    viewModel.startHapticEngine()
                    caregiverViewModel.startHapticEngine()
                    SoundManager.shared.reactivate()
                } else if phase == .background {
                    viewModel.stopHapticEngine()
                    caregiverViewModel.stopHapticEngine()
                }
            }
        }
        .captureHighlight(id: "tapArea")
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}

/// Displays Morse code characters with a highlight animation for the currently
/// playing symbol. Used within a speech message block.
struct AnimatedMorseView: View {
    let morse: String
    let currentIndex: Int?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 4) {
                    ForEach(Array(morse.enumerated()), id: \.offset) { index, char in
                        Text(String(char))
                            .foregroundColor(index == currentIndex ? .blue : .gray)
                            .scaleEffect(index == currentIndex ? 1.4 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                            .font(.system(size: 14, design: .monospaced))
                            .id(index)
                    }
                }
            }
            .onChange(of: currentIndex) { index in
                guard let index = index else { return }
                withAnimation {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
        }
    }
}

