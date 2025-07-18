import SwiftUI

struct OnboardingSheetView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color(.systemBackground).opacity(0.9).ignoresSafeArea()
            VStack {
                TabView {
                    VStack(spacing: 20) {
                        Image(systemName: "waveform.path")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color(red: 80/255, green: 200/255, blue: 120/255, opacity: 1))
                        Text("Welcome to HapticCommunicator")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Communicate using Morse code through haptics and speech. Please allow speech recognition when prompted.")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()

                    VStack(spacing: 20) {
                        Image(systemName: "rectangle.split.3x1.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.blue)
                        Text("Navigation")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Use the top tab bar to switch between User, Caregiver and Settings modes.")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()

                    VStack(alignment: .center, spacing: 36) {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "accessibility")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.green)
                            Text("User Mode")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading, spacing: 9) {
                            Label("Tap quickly for a dot", systemImage: "hand.tap")
                            Label("Hold slightly longer for a dash", systemImage: "hand.point.up.left.fill")
                            Label("Swipe right for a letter gap", systemImage: "arrow.right")
                            Label("Swipe up to decode the sequence", systemImage: "arrow.up")
                            Label("Long‑press anywhere for speech input", systemImage: "mic.fill")
                        }
                      // .font(.system(size: 17))
                    }
                    .padding()

                    VStack(alignment: .center, spacing: 36) {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "heart.text.square.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.blue)
                            Text("Caregiver Mode")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading, spacing: 9) {
                            Label("Type text into the field", systemImage: "keyboard")
                            Label("Tap Convert to Morse Code", systemImage: "arrowtriangle.right.fill")
                            Label("Hand over the phone and tap to play the vibration", systemImage: "hand.tap")
                        }
                    }
                    .padding()

                    VStack(alignment: .center, spacing: 36) {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "lightbulb.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.orange)
                            Text("Learn Morse Code")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading, spacing: 9) {
                            Label("Go to Settings", systemImage: "gearshape.fill")
                            Label("Tap 'Learn Morse Code'", systemImage: "hand.tap.fill")
                            Label("Explore each letter and feel its vibration", systemImage: "sparkles")
                            
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .padding()
            }
            .padding(.top, -10)
        }
    }
}

struct OnboardingView: View {
    @Binding var isPresented: Bool

    var body: some View {
        Color.clear
            .sheet(isPresented: $isPresented) {
                OnboardingSheetView(isPresented: $isPresented)
                    .presentationDetents([.fraction(0.60)])
                    .presentationCornerRadius(50)
            }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
    }
}
