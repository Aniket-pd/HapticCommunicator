//
//  UserView.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Full-screen tap area, live input, decoded text, audio feedback toggle


import SwiftUI

struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var isPressing = false
    @State private var showHelloWorld = false
    @State private var recognizedHistory: [String] = []
    @State private var speechMorseHistory: [String] = []
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
                    ForEach(Array(recognizedHistory.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text(item)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        HStack {
                            Text(speechMorseHistory[index])
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                            Spacer()
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
                                    recognizedHistory.append(liveRecognizedText)
                                    speechMorseHistory.append(liveMorseText)
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
