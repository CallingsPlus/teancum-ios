import DataStoreTypes

public class FirebaseDataStore { // : AppAPI {
    let currentUserProvider: CurrentUserProvider
    
    init(environment: FirebaseAPI.Environment) {
        let firebaseAPI = FirebaseAPI(environment: environment)
        let authenticationStateProvider = AuthenticationStateProvider()
        currentUserProvider = CurrentUserProvider(firebaseAPI: firebaseAPI, authenticationStateProvider: authenticationStateProvider)
    }
}

extension FirebaseDataStore {
    public var currentUser: CurrentUserProviding { currentUserProvider }
}
