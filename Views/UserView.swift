//
//  UserView.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Full-screen tap area, live input, decoded text, audio feedback toggle


import SwiftUI

struct UserView: View {
    @StateObject private var viewModel = UserViewModel()

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

                Text("Tap anywhere: Short tap = dot, Long tap = dash, Double tap = send")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle()) // Make entire area tappable
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        viewModel.handleTapStart()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.handleTapEnd()
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded {
                        viewModel.handleDoubleTap()
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
