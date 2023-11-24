import DataServices

public class FirebaseDataServices { // : DataServices {
    let currentUserProvider: CurrentUserProvider
    
    init(environment: FirebaseAPI.Environment) {
        let firebaseAPI = FirebaseAPI(environment: environment)
        let authenticationStateProvider = AuthenticationStateProvider()
        currentUserProvider = CurrentUserProvider(firebaseAPI: firebaseAPI, authenticationStateProvider: authenticationStateProvider)
    }
}

extension FirebaseDataServices {
    public var currentUser: any CurrentUserProviding { currentUserProvider }
}
