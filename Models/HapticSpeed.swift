import Foundation

enum HapticSpeed: String, CaseIterable, Identifiable {
    case verySlow
    case slow
    case standard
    case fast
    case veryFast

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .verySlow: return "Very Slow"
        case .slow: return "Slow"
        case .standard: return "Standard"
        case .fast: return "Fast"
        case .veryFast: return "Very Fast"
        }
    }

    /// Base unit duration for a dot in seconds
    var unitDuration: TimeInterval {
        switch self {
        case .verySlow: return 0.6
        case .slow: return 0.45
        case .standard: return 0.3
        case .fast: return 0.2
        case .veryFast: return 0.1
        }
    }
}
