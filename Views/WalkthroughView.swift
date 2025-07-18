import SwiftUI

struct WalkthroughView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                walkthroughPage(
                    title: "Welcome",
                    message: "Use the tabs at the top to switch between User, Caregiver and Settings modes.",
                    systemImage: "rectangle.3.offgrid"
                ).tag(0)

                walkthroughPage(
                    title: "User Mode",
                    message: "Tap quickly for ·, hold slightly for −. Swipe up to decode, swipe right for space, long‑press to dictate.",
                    systemImage: "hand.tap"
                ).tag(1)

                walkthroughPage(
                    title: "Caregiver Mode",
                    message: "Type text, convert to Morse and hand over the device. Tap anywhere in the sheet to play the vibration.",
                    systemImage: "person.2"
                ).tag(2)

                walkthroughPage(
                    title: "Settings",
                    message: "Adjust haptic speed and audio options here. You can repeat this tutorial anytime from Settings.",
                    systemImage: "gear"
                ).tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .navigationTitle("Tutorial")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(currentPage == 3 ? "Done" : "Next") {
                        if currentPage == 3 {
                            isPresented = false
                        } else {
                            withAnimation { currentPage += 1 }
                        }
                    }
                }
            }
        }
    }

    private func walkthroughPage(title: String, message: String, systemImage: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct WalkthroughView_Previews: PreviewProvider {
    static var previews: some View {
        WalkthroughView(isPresented: .constant(true))
    }
}
