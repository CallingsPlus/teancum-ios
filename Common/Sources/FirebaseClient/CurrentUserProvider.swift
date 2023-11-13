import CodeLocation
import Combine
import DataStoreTypes
import ExtendedFoundation
import FirebaseAuth
import FirebaseAuthUI
import Logging

extension CodeDomain where Self == String {
    static var currentUserProvider: CodeDomain { "ios.callings-plus.current-user-provider" }
}

public class CurrentUserProvider {
    private let firebaseClient: FirebaseClient
    private let authenticationStateProvider: AuthenticationStateProviding
    private var subscriptions = Set<AnyCancellable>()
    fileprivate let currentUserSubject = CurrentValueSubject<DataStoreTypes.User?, Never>(nil)
    
    public init(firebaseClient: FirebaseClient, authenticationStateProvider: AuthenticationStateProviding) {
        self.firebaseClient = firebaseClient
        self.authenticationStateProvider = authenticationStateProvider
        observeAuthenticationState()
    }
    
    private func observeAuthenticationState() {
        authenticationStateProvider
            .authStatePublisher
            .flatMap { [firebaseClient] state -> AnyPublisher<User?, Error> in
                switch state {
                case .signedIn(let firebaseUser, signOut: _):
                    return firebaseClient
                        .getUser(byID: firebaseUser.uid)
                        .executeAsPublisher()
                        .map { Optional.some($0) }
                        .eraseToAnyPublisher()
                case .signedOut:
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let failure) = result, let self {
                    failure.handle("Retrying user object load", in: .currentUserProvider)
                    observeAuthenticationState()
                }
            }, receiveValue: { [currentUserSubject] user in
                currentUserSubject.value = user
            })
            .store(in: &subscriptions)
    }
}

extension CurrentUserProvider: CurrentUserProviding {
    public var currentUser: DataStoreTypes.User? {
        return currentUserSubject.value
    }
    
    public var publisher: AnyPublisher<DataStoreTypes.User?, Never> {
        return currentUserSubject.eraseToAnyPublisher()
    }
}

public enum FirebaseClientError: Error {
    case notSignedIn
}
