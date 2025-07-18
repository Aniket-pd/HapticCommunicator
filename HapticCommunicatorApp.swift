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
    @StateObject private var onboardingManager = OnboardingManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(onboardingManager)
                .onAppear {
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
    }
}
