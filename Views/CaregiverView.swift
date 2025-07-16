//
//  CaregiverView.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Input field, Convert to Morse button, popup to hand over


import SwiftUI
import Combine

struct CaregiverView: View {
    @StateObject private var viewModel = CaregiverViewModel()
    @EnvironmentObject var settings: SettingsViewModel
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.inputText)
                        .font(.system(size: 22, weight: .semibold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .focused($isTextEditorFocused)

                    if viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Type your words here")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }
                .frame(minHeight: 150)
                .padding()

                Button(action: {
                    viewModel.convertTextToMorse()
                }) {
                    Text("Convert to Morse Code")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.inputText.isEmpty
                      ? Color.gray
                      : Color(red: 74 / 255, green: 144 / 255, blue: 226 / 255, opacity: 1))
                .animation(.easeInOut(duration: 0.3), value: viewModel.inputText.isEmpty)
                .controlSize(.regular)
                .disabled(viewModel.inputText.isEmpty)

                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.settings = settings
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextEditorFocused = true
                }
                viewModel.startHapticEngine()
            }
            .onDisappear {
                viewModel.stopHapticEngine()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $viewModel.isReadyForHandover) {
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 16) {
                            Text(viewModel.inputText)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 4) {
                                    ForEach(Array(viewModel.morseCode.enumerated()), id: \.offset) { index, char in
                                        Text(String(char))
                                            .foregroundColor(index == viewModel.currentSymbolIndex ? .blue : .gray)
                                            .scaleEffect(index == viewModel.currentSymbolIndex ? 1.4 : 1.0)
                                            .animation(.easeInOut(duration: 0.2), value: viewModel.currentSymbolIndex)
                                            .font(.title3)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)

                        Spacer()

                        Image(systemName: "hand.tap")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)

                        Text("Tap Anywhere")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("hand over your phone to the user and press anywhere to play the vibration")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        await viewModel.startVibration(speed: settings.selectedSpeed)
                        viewModel.isReadyForHandover = false
                    }
                }
                .presentationDetents([.fraction(0.8)])
            }
        }
    }
}

struct CaregiverView_Previews: PreviewProvider {
    static var previews: some View {
        CaregiverView()
    }
}
