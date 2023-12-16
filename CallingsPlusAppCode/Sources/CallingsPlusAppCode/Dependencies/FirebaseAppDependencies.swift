import DataServices
import FirebaseDataServices
import SwiftUI

class FirebaseAppDependencies: AppDependencies {
    let firebaseAPI: FirebaseAPI
    
    init(environment: FirebaseAPI.Environment) {
        self.firebaseAPI = .init(environment: environment)
    }
    
    // MARK: - AppDependencies Conformance
    
    lazy var authenticationStateProvider: FirebaseAuthenticationStateProvider = {
        FirebaseAuthenticationStateProvider(firebaseAPI: firebaseAPI)
    }()
    
    var authenticationView: some View {
        FirebaseAuthenticationViewBuilder().buildView(authStateProvider: authenticationStateProvider)
    }
    
    var membersService: FirebaseAPI {
        firebaseAPI
    }
}
