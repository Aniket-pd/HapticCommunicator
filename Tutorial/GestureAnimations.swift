import SwiftUI

/// Simple animations to illustrate onboarding gestures.
struct TapAnimationView: View {
    @State private var pressed = false
    var body: some View {
        Image(systemName: "hand.tap")
            .font(.system(size: 60))
            .foregroundColor(.white)
            .scaleEffect(pressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pressed)
            .onAppear { pressed = true }
    }
}

struct HoldAnimationView: View {
    @State private var scale: CGFloat = 1.0
    var body: some View {
        Image(systemName: "hand.raised.fill")
            .font(.system(size: 60))
            .foregroundColor(.white)
            .scaleEffect(scale)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: scale)
            .onAppear { scale = 0.8 }
    }
}

struct SwipeRightAnimationView: View {
    @State private var offset: CGFloat = -40
    var body: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: 60))
            .foregroundColor(.white)
            .offset(x: offset)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: offset)
            .onAppear { offset = 40 }
    }
}

struct SwipeUpAnimationView: View {
    @State private var offset: CGFloat = 40
    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 60))
            .foregroundColor(.white)
            .offset(y: offset)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: offset)
            .onAppear { offset = -40 }
    }
}
