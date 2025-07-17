//
//  HapticCommunicatorApp.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//

import SwiftUI
import Speech

@main
struct HapticCommunicatorApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
                    .onAppear(perform: requestSpeechAuthorization)
            } else {
                OnboardingView()
                    .onAppear(perform: requestSpeechAuthorization)
            }
        }
    }

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            default:
                print("Speech recognition NOT authorized")
            }
        }
    }
}
