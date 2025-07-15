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
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.inputText.isEmpty)

                Spacer()
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextEditorFocused = true
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $viewModel.isReadyForHandover) {
                VStack(spacing: 20) {
                    Text("Hand over your phone to the user and press Start to play the vibration.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: {
                        viewModel.startVibration()
                        viewModel.isReadyForHandover = false
                    }) {
                        Text("Start")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                }
                .presentationDetents([.fraction(0.3)])
            }
        }
    }
}

struct CaregiverView_Previews: PreviewProvider {
    static var previews: some View {
        CaregiverView()
    }
}
