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
            case .production(let firebaseAppDependencies),
                    .staging(let firebaseAppDependencies),
                    .localhost(let firebaseAppDependencies):
                MainView(dependencies: firebaseAppDependencies)
            case .mock(let stubAppDependencies):
                MainView(dependencies: stubAppDependencies)
            case .unitTest:
                EmptyView() // No need to load a view in this context
            }
        }
    }
}

enum CallingsPlusAppViewState {
    case initialized(DependencyLoaderModel)
    case production(FirebaseAppDependencies)
    case staging(FirebaseAppDependencies)
    case localhost(FirebaseAppDependencies)
    case mock(StubAppDependencies)
    case unitTest
    
    struct DependencyLoaderModel {
        func load() -> CallingsPlusAppViewState {
            switch AppEnvironment.current {
            case .production:
                .production(FirebaseAppDependencies(environment: .production))
            case .staging:
                .staging(FirebaseAppDependencies(environment: .staging))
            case .localhost:
                .localhost(FirebaseAppDependencies(environment: .localhost))
            case .mock:
                .mock(StubAppDependencies())
            case .unitTesting:
                .unitTest
            }
        }
    }
}
