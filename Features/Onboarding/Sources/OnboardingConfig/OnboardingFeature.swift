import FirebaseClient
@testable import Onboarding
import SwiftUI

public struct OnboardingFeature {
    public typealias Dependencies = Any
    let internalDependencies: InternalDependencies
    
    public init(dependencies: Dependencies) {
        internalDependencies = InternalDependencies()
    }
    
    public func getUnauthenticatedView() -> some View {
        UnauthenticatedView(dependencies: internalDependencies)
    }
}

struct InternalDependencies: UnauthenticatedViewDependencies {
    var authenticationViewProvider: AuthenticationViewProvider { AuthenticationViewProvider() }
}

extension AuthenticationViewProvider: ViewProviding { }
