import SwiftUI
import TipKit

struct OnboardingOverlay: View {
    @EnvironmentObject var onboarding: OnboardingManager

    private let dotTip = DotTip()
    private let dashTip = DashTip()
    private let spaceTip = SpaceTip()
    private let decodeTip = DecodeTip()
    private let micTip = MicTip()

    @State private var arrowWiggle = false

    var body: some View {
        Group {
            switch onboarding.currentStep {
            case .dot:
                TipView(dotTip)
                    .tipViewStyle(.spotlight)
                    .transition(.opacity)
            case .dash:
                TipView(dashTip)
                    .tipViewStyle(.spotlight)
                    .transition(.opacity)
            case .space:
                VStack {
                    TipView(spaceTip)
                        .tipViewStyle(.spotlight)
                    Image(systemName: "arrow.right")
                        .font(.largeTitle)
                        .offset(x: arrowWiggle ? 10 : -10)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: arrowWiggle)
                        .onAppear { arrowWiggle = true }
                }
                .transition(.opacity)
            case .decode:
                VStack {
                    TipView(decodeTip)
                        .tipViewStyle(.spotlight)
                    Image(systemName: "arrow.up")
                        .font(.largeTitle)
                        .offset(y: arrowWiggle ? -10 : 10)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: arrowWiggle)
                        .onAppear { arrowWiggle = true }
                }
                .transition(.opacity)
            case .mic:
                TipView(micTip)
                    .tipViewStyle(.spotlight)
                    .transition(.opacity)
            case .none:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topTrailing) {
            if onboarding.currentStep != nil {
                Button("Skip") { onboarding.skip() }
                    .padding()
            }
        }
        .overlay(alignment: .bottom) {
            if onboarding.currentStep != nil {
                Button(onboarding.currentStep == .mic ? "Done" : "Next") {
                    onboarding.advance()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Color.clear
            .overlay(OnboardingOverlay().environmentObject(OnboardingManager()))
    }
}
