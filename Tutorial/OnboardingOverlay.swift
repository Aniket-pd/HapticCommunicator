import SwiftUI

/// Identifies a step within the onboarding flow.
struct OnboardingStep: Identifiable {
    let id: String
    let message: String
    /// Optional animated visual shown above the instructional text.
    let visual: AnyView?

    init(id: String, message: String, visual: AnyView? = nil) {
        self.id = id
        self.message = message
        self.visual = visual
    }
}

/// Stores captured frames for highlighted SwiftUI views.
private struct HighlightPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

/// View modifier that reports its frame using a preference.
struct HighlightCapture: ViewModifier {
    let id: String
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: HighlightPreferenceKey.self,
                                    value: [id: proxy.frame(in: .global)])
                }
            )
    }
}

extension View {
    /// Capture the frame of this view for onboarding spotlighting.
    func captureHighlight(id: String) -> some View {
        modifier(HighlightCapture(id: id))
    }
}

/// Observable object managing onboarding progression.
final class OnboardingManager: ObservableObject {
    @Published var index: Int = 0
    let steps: [OnboardingStep]
    var onFinish: (() -> Void)?

    init(steps: [OnboardingStep]) {
        self.steps = steps
    }

    /// Advance to the next step, finishing when at end.
    func next() {
        index += 1
        if index >= steps.count {
            UserDefaults.standard.set(true, forKey: "didShowTutorial")
            onFinish?()
        }
    }

    var isFinished: Bool { index >= steps.count }
}

/// Shape used to cut a circular hole highlighting a UI element.
struct SpotlightShape: Shape {
    var container: CGRect
    var highlight: CGRect

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(container)
        path.addEllipse(in: highlight.insetBy(dx: -8, dy: -8))
        return path
    }
}

/// Semi-transparent overlay presenting onboarding instructions.
struct OnboardingOverlay: View {
    @ObservedObject var manager: OnboardingManager
    @State private var highlights: [String: CGRect] = [:]

    var body: some View {
        GeometryReader { proxy in
            if !manager.isFinished,
               let frame = highlights[manager.steps[manager.index].id] {
                ZStack {
                    // Dark overlay with circular cut-out around the highlighted item
                    Color.black.opacity(0.6)
                        .mask(
                            SpotlightShape(container: proxy.frame(in: .global),
                                          highlight: frame)
                                .fill(style: FillStyle(eoFill: true))
                        )
                        .ignoresSafeArea()
                        .onTapGesture { manager.next() }

                    VStack(spacing: 16) {
                        Spacer()
                        if let visual = manager.steps[manager.index].visual {
                            visual
                        }
                        Text(manager.steps[manager.index].message)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        Button("Next", action: manager.next)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
        .onPreferenceChange(HighlightPreferenceKey.self) { highlights = $0 }
    }
}
