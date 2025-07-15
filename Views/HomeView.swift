import SwiftUI

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
                            .fill(selectedTab == .userMode ? Color.blue : Color.gray.opacity(0.2))
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
                            .fill(selectedTab == .careTaker ? Color.blue : Color.gray.opacity(0.2))
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

    var body: some View {
        VStack(spacing: 0) {
            // Top tab bar
            TopTabBar(selectedTab: $selectedTab)

            Divider()

            // Main content area
            Group {
                switch selectedTab {
                case .userMode:
                    UserView()
                case .careTaker:
                    CaregiverView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.default, value: selectedTab) // Optional: adds smooth switch animation
        }
    }
}

// Placeholder views (replace with your real views)
struct SettingsView: View {
    var body: some View {
        Text("Settings View")
            .font(.largeTitle)
            .padding()
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
