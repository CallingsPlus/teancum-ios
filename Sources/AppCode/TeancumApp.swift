import FirebaseClient
import SwiftUI
import VSM

typealias TeancumAppDependencies = UnauthenticatedViewDependencies

@main
struct TeancumApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ViewState var state: TeancumAppViewState = .initialized(.init())
    
    var body: some Scene {
        WindowGroup {
            switch state {
            case .initialized(let loaderModel):
                HStack { }.onAppear { $state.observe(loaderModel.load()) }
            case .loading:
                ExtendedLaunchView()
            case .loaded(let loadedModel):
                // TODO: Check authentication state and set root view as necessary
                UnauthenticatedView(dependencies: loadedModel.dependencies)
            }
        }
    }
}
