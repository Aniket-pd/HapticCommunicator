import SwiftUI
import TipKit

@available(iOS 17, *)
struct HomeUserTip: Tip {
    var title: Text { Text("User Mode") }
    var message: Text? { Text("Switch to User mode for sending Morse code gestures.") }
    var image: Image? { Image(systemName: "person") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}

@available(iOS 17, *)
struct HomeCaregiverTip: Tip {
    var title: Text { Text("Caregiver Mode") }
    var message: Text? { Text("Switch to Caregiver mode to type text and send vibrations.") }
    var image: Image? { Image(systemName: "hands.sparkles") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}

@available(iOS 17, *)
struct HomeSettingsTip: Tip {
    var title: Text { Text("Settings") }
    var message: Text? { Text("Adjust vibration speed and sound options here.") }
    var image: Image? { Image(systemName: "gearshape") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}

@available(iOS 17, *)
struct TapDotTip: Tip {
    var title: Text { Text("Tap Dot Button") }
    var message: Text? { Text("Tap this button once to send a dot — the shortest Morse code signal!") }
    var image: Image? { Image(systemName: "circle.fill") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}

@available(iOS 17, *)
struct TapDashTip: Tip {
    var title: Text { Text("Tap and Hold for Dash") }
    var message: Text? { Text("Press and hold here to send a dash — hold a bit longer for a stronger signal!") }
    var image: Image? { Image(systemName: "minus") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}

@available(iOS 17, *)
struct SwipeSpaceTip: Tip {
    var title: Text { Text("Add Space Between Letters") }
    var message: Text? { Text("Swipe right here to add a space between letters — keep your message readable!") }
    var image: Image? { Image(systemName: "arrow.right") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}

@available(iOS 17, *)
struct SendTip: Tip {
    var title: Text { Text("Send & Decode Message") }
    var message: Text? { Text("All done? Tap the send button to decode your Morse code into readable text!") }
    var image: Image? { Image(systemName: "paperplane.fill") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}

@available(iOS 17, *)
struct MicTip: Tip {
    var title: Text { Text("Enable Mic by Holding Screen") }
    var message: Text? { Text("Hold anywhere on the screen to enable the microphone — speak your message hands-free!") }
    var image: Image? { Image(systemName: "mic.fill") }
    var rules: [Rule] { [MaxDisplayCountRule(count: 1)] }
}
