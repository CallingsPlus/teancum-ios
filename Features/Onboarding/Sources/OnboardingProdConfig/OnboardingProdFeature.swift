import FirebaseDataServices
import Onboarding
import SwiftUI

public struct ProdDependencies: OnboardingFeatureDependencies {
    public var firebaseAPI: FirebaseAPI
    public var authenticationView: some View {
        FirebaseAuthenticationViewBuilder().buildView(authStateProvider: FirebaseAuthenticationStateProvider(firebaseAPI: firebaseAPI))
    }
}

public extension OnboardingFeature where Dependencies == ProdDependencies {
    static func prod(firebaseAPI: FirebaseAPI) -> Self {
        OnboardingFeature(dependencies: ProdDependencies(firebaseAPI: firebaseAPI))
    }
}
