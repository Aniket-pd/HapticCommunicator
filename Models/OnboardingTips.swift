//
//  OnboardingTips.swift
//  HapticCommunicator
//
//  Contains TipKit tips used for onboarding.
//

import SwiftUI
import TipKit

/// Tip shown when teaching the user how to send a dot.
struct DotTip: Tip {
    var title: Text { Text("Tap Dot") }
    var message: Text? { Text("Tap here once to send a dot — the short signal in Morse code!") }
}

/// Tip shown when teaching the user how to send a dash.
struct DashTip: Tip {
    var title: Text { Text("Tap Dash") }
    var message: Text? { Text("Press and hold here to send a dash — hold a little longer for a stronger signal!") }
}

/// Tip shown for adding spaces between letters.
struct SpaceTip: Tip {
    var title: Text { Text("Letter Space") }
    var message: Text? { Text("Swipe right here to add a space between letters — keep your message clear!") }
}

/// Tip shown for decoding the current Morse message.
struct SendTip: Tip {
    var title: Text { Text("Send Message") }
    var message: Text? { Text("Tap the send button to decode your Morse code into readable text!") }
}

/// Tip shown for enabling microphone input.
struct MicTip: Tip {
    var title: Text { Text("Enable Microphone") }
    var message: Text? { Text("Press and hold anywhere on the screen to enable microphone input — you can now speak your message!") }
}
