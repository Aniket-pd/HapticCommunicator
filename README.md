# HapticCommunicator

HapticCommunicator is an iOS app for communicating using Morse code through haptic feedback. The project is written in SwiftUI and follows a simple MVVM structure.

## Main Screens

* **User** – full-screen tap area for entering Morse or holding to dictate speech. Swipe up to convert the Morse input to text, or swipe right to insert a space. Speech input is converted to Morse and vibrated for the caregiver.
* **Caregiver** – type text, convert it to Morse code and hand the device to the user so the message can be played back as vibration.
* **Settings** – pick haptic speed, preview the selected speed and toggle beep and speech sounds.

Switch between these views using the top tab bar in `HomeView`.

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
