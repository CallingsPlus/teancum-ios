import SwiftUI

public typealias OnboardingFeatureDependencies = UnauthenticatedViewDependencies

public struct OnboardingFeature<Dependencies: OnboardingFeatureDependencies> {
    let dependencies: Dependencies
    
    public var onboardingView: some View {
        UnauthenticatedView(dependencies: dependencies)
    }
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
