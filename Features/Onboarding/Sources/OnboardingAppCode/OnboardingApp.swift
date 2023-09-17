import Onboarding
import OnboardingMockConfig
import SwiftUI

@main
struct OnboardingApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingFeature.mocked.onboardingView
        }
    }
}
