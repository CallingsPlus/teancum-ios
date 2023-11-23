import DataStoreTypes

public class FirebaseDataStore { // : AppAPI {
    let currentUserProvider: CurrentUserProvider
    let membersProvider: MembersProvider
    
    init(environment: FirebaseAPI.Environment) {
        let firebaseAPI = FirebaseAPI(environment: environment)
        let authenticationStateProvider = AuthenticationStateProvider()
        currentUserProvider = CurrentUserProvider(firebaseAPI: firebaseAPI, authenticationStateProvider: authenticationStateProvider)
        membersProvider = MembersProvider(firebaseAPI: firebaseAPI, unitID: "")
    }
}

extension FirebaseDataStore {
    public var currentUser: CurrentUserProviding { currentUserProvider }
    public var members: MemberProviding { membersProvider }
}
