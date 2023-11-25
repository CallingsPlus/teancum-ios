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
                OnboardingFeature.prod(firebaseAPI: FirebaseAPI(environment: .prod)).onboardingView
            }
        }
    }
}
