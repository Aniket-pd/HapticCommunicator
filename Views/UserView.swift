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
    @State private var isPressing = false
    @State private var showHelloWorld = false
    @State private var messageHistory: [Message] = []
    @State private var liveRecognizedText: String = ""
    @State private var liveMorseText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text(viewModel.decodedText.isEmpty ? "Decoded text will be displayed here" : viewModel.decodedText)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal)

                HStack {
                    Spacer()
                    Text(viewModel.morseHistory.isEmpty ? "Morse code history will appear here" : viewModel.morseHistory)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(nil)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(messageHistory) { message in
                        if message.isSpeech {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(message.text)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(Color.primary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                HStack {
                                    Text(message.morse)
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                        } else {
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack {
                                    Spacer()
                                    Text(message.text)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(Color.primary)
                                        .multilineTextAlignment(.trailing)
                                }
                                HStack {
                                    Spacer()
                                    Text(message.morse)
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

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
                            viewModel.handleTapStart()
                        }
                    }
                    .onEnded { value in
                        isPressing = false
                        if value.translation.height < -50 {
                            // Swipe up → send the full message
                            viewModel.handleDoubleTap()
                            messageHistory.append(Message(text: viewModel.decodedText, morse: viewModel.morseHistory, isSpeech: false))
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
