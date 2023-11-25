import FirebaseDataServices
import Onboarding
import OnboardingProdConfig
import SwiftUI
import VSM

typealias CallingsPlusAppDependencies = Any

@main
struct CallingsPlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ViewState var state: CallingsPlusAppViewState = .initialized(.init())
    
    var body: some Scene {
        WindowGroup {
            switch state {
            case .initialized(let loaderModel):
                HStack { }.onAppear { $state.observe(loaderModel.load()) }
            case .loading:
                ExtendedLaunchView()
            case .loaded(let loadedModel):
                // TODO: Check authentication state and set root view as necessary
                let environment = getEnvironmentFromLaunchArguments()
                OnboardingFeature.prod(firebaseAPI: FirebaseAPI(environment: environment)).onboardingView
            }
        }
    }
    
    /// Parses launch arguments for the desired app environment.
    private func getEnvironmentFromLaunchArguments() -> FirebaseAPI.Environment {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-prod") {
            return .prod
        } else if arguments.contains("-stage") || arguments.contains("-staging") {
            return .staging
        } else if arguments.contains("-dev") {
            return .dev
        } else {
            return .prod
        }
    }
}
