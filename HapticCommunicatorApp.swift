//
//  HapticCommunicatorApp.swift
//  HapticCommunicator
//
//  Created by Aniket prasad on 11/7/25.
//

import SwiftUI
import Speech
import AVFoundation

@main
struct HapticCommunicatorApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    SFSpeechRecognizer.requestAuthorization { authStatus in
                        switch authStatus {
                        case .authorized:
                            print("Speech recognition authorized")
                        default:
                            print("Speech recognition NOT authorized")
                        }
                    }

                    AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                        if allowed {
                            print("Microphone access granted")
                        } else {
                            print("Microphone access NOT granted")
                        }
                    }
                }
                .onAppear {
                    IntroHapticsPlayer.shared.play()
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        IntroHapticsPlayer.shared.play()
                    }
                }
        }
    }
}
