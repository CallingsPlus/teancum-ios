import FirebaseClient
import FirebaseCore
import SwiftUI
import VSM

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct TeancumApp: App {
    typealias Dependencies = Any
    
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
                UnauthenticatedView()
            }
        }
    }
}
