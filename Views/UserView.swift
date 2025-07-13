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
                                Text("Hello World")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            )
                            .onTapGesture {
                                withAnimation {
                                    showHelloWorld = false
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
