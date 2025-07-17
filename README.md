# HapticCommunicator

HapticCommunicator is an iOS app for communicating using Morse code through haptic feedback. The project is written in SwiftUI and follows a simple MVVM structure.

## Main Screens

* **User** – full-screen tap area for entering Morse or holding to dictate speech. Swipe up to convert the Morse input to text, or swipe right to insert a space. Speech input is converted to Morse and vibrated for the caregiver.
* **Caregiver** – type text, convert it to Morse code and hand the device to the user so the message can be played back as vibration.
* **Settings** – pick haptic speed, preview the selected speed and toggle beep and speech sounds.

Switch between these views using the top tab bar in `HomeView`.

## View Guide

Below is a quick reference to the main screens and how they work together:

### User View

The User view is a full-screen surface for entering Morse code. Tap quickly to
send a dot, hold to send a dash and swipe right to insert a letter space. Swipe
up to decode what you have typed so far. Long pressing anywhere triggers speech
dictation. While dictating, the spoken words are converted to Morse code and
vibrated for the caregiver.

### Caregiver View

The Caregiver view lets a helper type normal text and convert it to Morse code
vibrations for the user. Once converted, a sheet prompts the caregiver to hand
over the device and tap anywhere to play back the vibration sequence.

### Settings View

The Settings screen allows selecting the vibration speed and toggling beep or
speech sounds. A short demo text shows how the current speed feels.

Each view runs its own haptic engine but they share `SettingsViewModel` through
environment objects so changes apply immediately across the app.

## Onboarding

First-time users are guided through the main screens and gestures with a TipKit-powered tutorial. Each step highlights the relevant area of the screen and explains how to:

1. Switch to **User** mode.
2. Switch to **Caregiver** mode.
3. Open **Settings**.
4. Tap once for a dot.
5. Hold to send a dash.
6. Swipe right to add a space.
7. Swipe up to decode the message.
8. Hold anywhere to start dictating with the microphone.

Tips only appear on the first launch but can be reset from `OnboardingManager` for testing.

## Usage Basics

1. Open the app and allow speech recognition when prompted.
2. In **User** mode:
   * Tap short/long for dots and dashes.
   * Swipe up to decode the current sequence.
   * Swipe right for a letter gap.
   * Hold for a couple seconds to speak instead of tapping.
3. In **Caregiver** mode, enter text and tap **Convert to Morse Code**. A sheet appears instructing you to hand the device to the user and tap anywhere to play the vibration.

## Build & Run

1. Open `HapticCommunicator.xcodeproj` in Xcode.
2. Select the **HapticCommunicator** scheme.
3. Build and run with `⌘R` or from the menu (`Product › Run`).

Alternatively from the command line:

```bash
xcodebuild -scheme HapticCommunicator -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Tests

Run the tests in Xcode with `⌘U` or use `xcodebuild`:

```bash
xcodebuild test -scheme HapticCommunicator -destination 'platform=iOS Simulator,name=iPhone 15'
```
