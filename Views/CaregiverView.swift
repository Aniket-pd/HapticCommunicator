//
//  CaregiverView.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//  Input field, Convert to Morse button, popup to hand over


import SwiftUI

struct CaregiverView: View {
    @StateObject private var viewModel = CaregiverViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextEditor(text: $viewModel.inputText)
                    .padding()
                    .frame(height: 150)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.separator), lineWidth: 1)
                    )
                    .accessibilityLabel("Enter your message")

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
            .navigationTitle("Caregiver Mode")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Show info or help view
                    } label: {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Info")
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
