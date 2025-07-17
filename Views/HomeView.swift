import SwiftUI
import TipKit

// Enum to track selected tab
enum TopTab {
    case userMode, careTaker, settings
}

// Reusable TopTabBar component
struct TopTabBar: View {
    @Binding var selectedTab: TopTab

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                selectedTab = .userMode
            }) {
                Text("User Modes")
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == .userMode ? .white : .primary)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == .userMode ? Color(red: 80/255, green: 200/255, blue: 120/255, opacity: 1) : Color.gray.opacity(0.2))
                    )
                    .shadow(radius: selectedTab == .userMode ? 4 : 0)
            }

            Button(action: {
                selectedTab = .careTaker
            }) {
                Text("CareTaker")
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == .careTaker ? .white : .primary)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == .careTaker ? Color(red: 74/255, green: 144/255, blue: 226/255, opacity: 1) : Color.gray.opacity(0.2))
                    )
                    .shadow(radius: selectedTab == .careTaker ? 4 : 0)
            }

            Button(action: {
                selectedTab = .settings
            }) {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .padding(8)
                    .foregroundColor(selectedTab == .settings ? .white : .primary)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == .settings ? Color.blue : Color.gray.opacity(0.2))
                    )
                    .shadow(radius: selectedTab == .settings ? 4 : 0)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .animation(.easeInOut, value: selectedTab)
    }
}

// Main HomeView with view switcher
struct HomeView: View {
    @State private var selectedTab: TopTab = .userMode
    @StateObject private var settings = SettingsViewModel()
    @StateObject private var onboarding = OnboardingManager()

    var body: some View {
        VStack(spacing: 0) {
            // Top tab bar
            TopTabBar(selectedTab: $selectedTab)

            Divider()

            // Main content area with smooth transitions
            ZStack {
                if selectedTab == .userMode {
                    UserView()
                        .environmentObject(settings)
                        .transition(.opacity)
                }
                if selectedTab == .careTaker {
                    CaregiverView()
                        .environmentObject(settings)
                        .transition(.opacity)
                }
                if selectedTab == .settings {
                    SettingsView()
                        .environmentObject(settings)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut, value: selectedTab)
        }
        .overlay(
            Group {
                if selectedTab == .userMode {
                    OnboardingOverlay()
                        .environmentObject(onboarding)
                }
            }
        )
    }
}

//// Preview
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//            .environmentObject(SettingsViewModel())
//    }
//}
