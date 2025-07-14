//
//  UserView.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Full-screen tap area, live input, decoded text, audio feedback toggle


import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let morse: String
    let isSpeech: Bool // true = speech, false = decoded
}

struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
    @StateObject private var caregiverViewModel = CaregiverViewModel()
    @State private var isPressing = false
    @State private var showHelloWorld = false
    @State private var messageHistory: [Message] = [
        Message(text: "Decoded text will be displayed here", morse: "Morse code history will appear here", isSpeech: false)
    ]
    @State private var liveRecognizedText: String = ""
    @State private var liveMorseText: String = ""

    var body: some View {
        NavigationStack {
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
                                            Text(message.morse)
                                                .font(.system(size: 14, design: .monospaced))
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        } else {
                                            Spacer()
                                            Text(message.morse)
                                                .font(.system(size: 14, design: .monospaced))
                                                .foregroundColor(.gray)
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

                Text("Tap anywhere: Tap rhythmically; swipe up to send")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressing {
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
                        withAnimation {
                            showHelloWorld = true
                        }
                        viewModel.startListening { text in
                            let converter = MorseCodeConverter()
                            let morse = converter.textToMorse(text)
                            liveRecognizedText = text
                            liveMorseText = morse
                        }
                    }
            )
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleAudioFeedback()
                    } label: {
                        Image(systemName: viewModel.audioFeedbackEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    }
                    .accessibilityLabel("Toggle audio feedback")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear History") {
                        messageHistory.removeAll()
                    }
                }
            }
            .overlay(
                Group {
                    if showHelloWorld {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .overlay(
                                VStack(spacing: 20) {
                                    Text("Hello World")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text(liveRecognizedText.isEmpty ? "Listening..." : liveRecognizedText)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                }
                            )
                            .onTapGesture {
                                withAnimation {
                                    showHelloWorld = false
                                }
                                viewModel.stopListening()
                                if !liveRecognizedText.isEmpty {
                                    messageHistory.append(Message(text: liveRecognizedText, morse: liveMorseText, isSpeech: true))
                                    
                                    caregiverViewModel.morseCode = liveMorseText
                                    caregiverViewModel.startVibration()
                                    
                                    liveRecognizedText = ""
                                    liveMorseText = ""
                                }
                            }
                    }
                }
            )
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
