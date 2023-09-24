import Onboarding
import SwiftUI

public struct MockDependencies: OnboardingFeatureDependencies {
    public var authenticationView: some View { Text("Mocked Authentication View") }
}

public extension OnboardingFeature where Dependencies == MockDependencies {
    static var mocked: Self {
        OnboardingFeature(dependencies: MockDependencies())
    }
}
