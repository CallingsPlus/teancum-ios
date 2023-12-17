import Combine
import DataServices
import Features
import SwiftUI
import StubDataServices
import VSM

typealias MainViewDependencies = MainTabViewDependencies & OnboardingViewDependencies & MainViewStateDependencies

struct MainView<Dependencies: MainViewDependencies>: View {
    let dependencies: Dependencies
    @ViewState var state: MainViewState = .initialized(.init())
    
    var body: some View {
        switch state {
        case .initialized(let loaderModel):
            HStack { }.onAppear { $state.observe(loaderModel.load(dependencies: dependencies)) }
        case .loading:
            ExtendedLaunchView()
        case .authenticated:
            MainTabView(dependencies: dependencies)
        case .unauthenticated:
            OnboardingView(dependencies: dependencies)
        }
    }
}
    
typealias MainViewStateDependencies = AuthenticationStateProvidingDependency

enum MainViewState {
    case initialized(LoaderModel)
    case loading
    case authenticated
    case unauthenticated
    
    struct LoaderModel {
        func load<Dependencies: MainViewStateDependencies>(dependencies: Dependencies) -> some Publisher<MainViewState, Never> {
            dependencies.authenticationStateProvider.statePublisher.map { authState in
                switch authState {
                case .error, .signedOut:
                    MainViewState.unauthenticated
                case .initializing:
                    MainViewState.loading
                case .signedIn:
                    MainViewState.authenticated
                }
            }
        }
    }
}
