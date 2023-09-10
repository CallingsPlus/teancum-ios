@testable import Onboarding
import SwiftUI

public struct OnboardingMockFeature {
    let internalDependencies: InternalDependencies = InternalDependencies()
    
    public init() { }
    
    public func getUnauthenticatedView() -> some View {
        UnauthenticatedView(dependencies: internalDependencies)
    }
}

struct InternalDependencies: UnauthenticatedViewDependencies {
    var authenticationViewProvider: some ViewProviding { .Mock(view: Text("Mock Authentication View")) }
}
