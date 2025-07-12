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

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text(viewModel.decodedText.isEmpty ? "Decoded text will be displayed here" : viewModel.decodedText)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(viewModel.morseInput)
                    .font(.system(size: 28, design: .monospaced))
                    .foregroundColor(.primary)
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
                        // Detect swipe up: if vertical translation is sufficiently negative, treat as send
                        if value.translation.height < -50 {
                            // TODO: call send handler, e.g., viewModel.handleDoubleTap() if that's intended
                            viewModel.handleDoubleTap()
                        } else {
                            viewModel.handleTapEnd()
                        }
                    }
            )
            .padding()
            .navigationTitle("User Mode")
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
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
