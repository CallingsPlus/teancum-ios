import FirebaseClient
import Onboarding
import SwiftUI

public struct ProdDependencies: OnboardingFeatureDependencies {
    public var authenticationView: some View {
        AuthenticationViewProvider().view
    }
}

public extension OnboardingFeature where Dependencies == ProdDependencies {
    static var prod: Self {
        OnboardingFeature(dependencies: ProdDependencies())
    }
}
