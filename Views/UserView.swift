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
    @State private var recognizedText = ""
    @State private var speechMorseCode = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text(viewModel.decodedText.isEmpty ? "Decoded text will be displayed here" : viewModel.decodedText)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal)

                HStack {
                    Text(viewModel.morseHistory.isEmpty ? "Morse code history will appear here" : viewModel.morseHistory)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    Spacer()
                }
                .padding(.horizontal)

                HStack {
                    Spacer()
                    Text(recognizedText.isEmpty ? "Speech will appear here" : recognizedText)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Text(speechMorseCode.isEmpty ? "Speech Morse code will appear here" : speechMorseCode)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
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
                            recognizedText = text
                            let converter = MorseCodeConverter()
                            speechMorseCode = converter.textToMorse(text)
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
                                    Text(recognizedText.isEmpty ? "Listening..." : recognizedText)
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

