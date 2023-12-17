import DataServices

public class FirebaseDataServices {
    
    init(environment: FirebaseAPI.Environment) {
        let firebaseAPI = FirebaseAPI(environment: environment)
        let authenticationStateProvider = FirebaseAuthenticationStateProvider(firebaseAPI: firebaseAPI)
    }
}

extension FirebaseDataServices {
}
