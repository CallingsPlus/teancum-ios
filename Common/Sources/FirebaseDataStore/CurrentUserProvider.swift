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
    private let firebaseAPI: FirebaseAPI
    private let authenticationStateProvider: AuthenticationStateProviding
    private var subscriptions = Set<AnyCancellable>()
    fileprivate let currentUserSubject = CurrentValueSubject<DataStoreTypes.User?, Never>(nil)
    
    public init(firebaseAPI: FirebaseAPI, authenticationStateProvider: AuthenticationStateProviding) {
        self.firebaseAPI = firebaseAPI
        self.authenticationStateProvider = authenticationStateProvider
        observeAuthenticationState()
    }
    
    private func observeAuthenticationState() {
        authenticationStateProvider
            .authStatePublisher
            .flatMap { [firebaseAPI] state -> AnyPublisher<FirebaseUser?, Error> in
                switch state {
                case .signedIn(let firebaseUser, signOut: _):
                    return firebaseAPI
                        .getUser(byID: firebaseUser.uid)
                        .publisher
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
    public var value: DataStoreTypes.User? {
        return currentUserSubject.value
    }
    
    public var publisher: AnyPublisher<DataStoreTypes.User?, Never> {
        return currentUserSubject.eraseToAnyPublisher()
    }
}
