import FirebaseDataServices
import Onboarding
import SwiftUI

public struct ProdDependencies: OnboardingFeatureDependencies {
    public var authenticationView: some View {
        FirebaseAuthenticationViewBuilder().buildView(authStateProvider: AuthenticationStateProvider())
    }
}

public extension OnboardingFeature where Dependencies == ProdDependencies {
    static var prod: Self {
        OnboardingFeature(dependencies: ProdDependencies())
    }
}
