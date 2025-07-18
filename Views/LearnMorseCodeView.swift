import SwiftUI

struct LearnMorseCodeView: View {
    @StateObject private var viewModel = LearnMorseCodeViewModel()
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase

    private let converter = MorseCodeConverter()
    private let letters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789")

    var body: some View {
        List(letters, id: \.self) { letter in
            let morse = converter.textToMorse(String(letter))
            Button(action: {
                viewModel.play(morse: morse, for: letter, speed: settings.selectedSpeed)
            }) {
                HStack {
                    Text(String(letter))
                        .font(.headline)
                        .padding(.leading, 16)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(Array(morse.enumerated()), id: \.offset) { index, symbol in
                            Text(String(symbol))
                                .font(.system(.title2, design: .monospaced))
                                .foregroundColor(viewModel.activeLetter == letter && viewModel.currentSymbolIndex == index ? .blue : .gray)
                                .scaleEffect(viewModel.activeLetter == letter && viewModel.currentSymbolIndex == index ? 1.4 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.currentSymbolIndex)
                        }
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Learn Morse Code")
        .onAppear {
            viewModel.startHapticEngine()
        }
        .onDisappear {
            viewModel.stopHapticEngine()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                viewModel.startHapticEngine()
                SoundManager.shared.reactivate()
            } else if phase == .background {
                viewModel.stopHapticEngine()
            }
        }
    }
}

struct LearnMorseCodeView_Previews: PreviewProvider {
    static var previews: some View {
        LearnMorseCodeView()
            .environmentObject(SettingsViewModel())
    }
}
