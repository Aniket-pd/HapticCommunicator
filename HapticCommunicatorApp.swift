//
//  HapticCommunicatorApp.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//

import SwiftUI
import Speech
import TipKit

@main
struct HapticCommunicatorApp: App {
    @StateObject private var onboarding = OnboardingManager()
    init() {
        if #available(iOS 17, *) {
            try? Tips.configure()
        }
    }
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(onboarding)
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
