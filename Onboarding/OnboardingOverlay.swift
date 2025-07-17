import SwiftUI

/// Overlay view that dims the background and highlights a target rect with instructional text.
struct OnboardingOverlay: View {
    let targetRect: CGRect
    let message: String
    let advance: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.6)
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .blendMode(.destinationOut)
                                .frame(width: targetRect.width + 16, height: targetRect.height + 16)
                                .position(x: targetRect.midX, y: targetRect.midY)
                        )
                        .compositingGroup()
                )
                .ignoresSafeArea()
                .onTapGesture { advance() }

            VStack(alignment: .leading, spacing: 12) {
                Text(message)
                    .foregroundColor(.white)
                    .font(.body)
                    .multilineTextAlignment(.leading)

                Button("Next") { advance() }
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 260)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
            .position(x: targetRect.minX, y: min(targetRect.maxY + 60, UIScreen.main.bounds.height - 80))
        }
        .animation(.easeInOut, value: targetRect)
    }
}
