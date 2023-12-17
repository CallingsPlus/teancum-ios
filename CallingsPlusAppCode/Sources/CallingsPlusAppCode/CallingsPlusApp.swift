import Combine
import DataServices
import FirebaseDataServices
import StubDataServices
import SwiftUI
import VSM

/// All dependency typealiases roll up to this type to be satisfied with concrete implementations
/// For more information, ask Dude about Composed Protocol Dependency injection
typealias AppDependencies = MainViewDependencies

@main
struct CallingsPlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ViewState var state: CallingsPlusAppViewState = .initialized(CallingsPlusAppViewState.DependencyLoaderModel())
    
    var body: some Scene {
        WindowGroup {
            switch state {
            case .initialized(let loaderModel):
                HStack { }.onAppear { $state.observe(loaderModel.load()) }
            case .firebaseDependenciesLoaded(let firebaseAppDependencies):
                MainView(dependencies: firebaseAppDependencies)
            case .mockDependenciesLoaded(let stubAppDependencies):
                MainView(dependencies: stubAppDependencies)
            case .unitTestDetected:
                EmptyView() // No need to load a view in this context
            }
        }
    }
}

enum CallingsPlusAppViewState {
    case initialized(DependencyLoaderModel)
    case firebaseDependenciesLoaded(FirebaseAppDependencies)
    case mockDependenciesLoaded(StubAppDependencies)
    case unitTestDetected
    
    struct DependencyLoaderModel {
        func load() -> CallingsPlusAppViewState {
            switch AppEnvironment.current {
            case .production:
                .firebaseDependenciesLoaded(FirebaseAppDependencies(environment: .production))
            case .staging:
                .firebaseDependenciesLoaded(FirebaseAppDependencies(environment: .staging))
            case .localhost:
                .firebaseDependenciesLoaded(FirebaseAppDependencies(environment: .localhost))
            case .mock:
                .mockDependenciesLoaded(StubAppDependencies())
            case .unitTesting:
                .unitTestDetected
            }
        }
    }
}
