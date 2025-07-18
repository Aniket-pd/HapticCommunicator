//
//  OnboardingManager.swift
//  HapticCommunicator
//
//  Created as part of tutorial feature.
//  Tracks onboarding progress and stores completion flag.
//

import Foundation
import TipKit

/// Handles tutorial state and progression through the onboarding steps.
final class OnboardingManager: ObservableObject {
    /// Individual onboarding steps presented to the user in order.
    enum Step: Int, CaseIterable {
        case tapDot
        case tapDash
        case addSpace
        case send
        case enableMic
    }

    /// Currently visible step. `nil` means onboarding finished.
    @Published var currentStep: Step? = nil

    private let defaultsKey = "isOnboardingCompleted"

    init() {
        // If the flag is not set, start with the first step
        if !UserDefaults.standard.bool(forKey: defaultsKey) {
            currentStep = .tapDot
        }
    }

    /// Advance to the next step or mark onboarding completed.
    func advance() {
        guard let step = currentStep,
              let index = Step.allCases.firstIndex(of: step) else {
            complete()
            return
        }
        let nextIndex = Step.allCases.index(after: index)
        if nextIndex < Step.allCases.endIndex {
            currentStep = Step.allCases[nextIndex]
        } else {
            complete()
        }
    }

    /// Skip remaining steps and mark onboarding completed.
    func skip() {
        complete()
    }

    /// Reset the onboarding state so the tutorial can be replayed.
    func reset() {
        UserDefaults.standard.set(false, forKey: defaultsKey)
        currentStep = .tapDot
    }

    private func complete() {
        UserDefaults.standard.set(true, forKey: defaultsKey)
        currentStep = nil
    }
}
