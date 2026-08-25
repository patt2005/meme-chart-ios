import SwiftUI

@main
struct MemeCoinApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
                .preferredColorScheme(.dark)
            }
        }
    }
}
