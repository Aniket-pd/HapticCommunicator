import SwiftUI
import TipKit

struct DotTip: Tip {
    var title: Text {
        Text("Tap a dot")
    }
    var message: Text? {
        Text("Quickly tap the screen for a dot")
    }
    var image: Image? {
        Image(systemName: "circle.fill")
    }
}

struct DashTip: Tip {
    var title: Text {
        Text("Hold for dash")
    }
    var message: Text? {
        Text("A longer press registers a dash")
    }
    var image: Image? {
        Image(systemName: "minus")
    }
}

struct SpaceTip: Tip {
    var title: Text {
        Text("Swipe right for space")
    }
    var message: Text? {
        Text("Insert a space between letters")
    }
    var image: Image? {
        Image(systemName: "arrow.right")
    }
}

struct SendTip: Tip {
    var title: Text {
        Text("Swipe up to send")
    }
    var message: Text? {
        Text("Decode your Morse input and speak it")
    }
    var image: Image? {
        Image(systemName: "arrow.up")
    }
}

struct MicTip: Tip {
    var title: Text {
        Text("Hold to speak")
    }
    var message: Text? {
        Text("Long press anywhere to dictate a message")
    }
    var image: Image? {
        Image(systemName: "mic.fill")
    }
}
