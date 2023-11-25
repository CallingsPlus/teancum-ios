import Combine

/// The possible states of authentication.
public enum AuthenticationState<SomeUser> {
    /// User authentication state is currently unknown while the process initializes
    case initializing
    /// User is signed in with a object and a signOut closure
    case signedIn(SomeUser, signOut: () -> Void)
    /// User is signed out
    case signedOut
    /// User state is unable to be determined, even after some number of automatic retries
    case error(Error)
    
    /// The user, if in the signedIn state.
    /// Returns nil if in the signedOut state.
    public var user: SomeUser? {
        switch self {
        case .signedIn(let user, _):
            return user
        case .initializing, .signedOut, .error:
            return nil
        }
    }
}

/// A protocol for providing authentication state.
public protocol AuthenticationStateProviding<SomeUser> {
    associatedtype SomeUser
    /// Current authentication state
    var state: AuthenticationState<SomeUser> { get }
    /// Publisher for authentication state changes
    var statePublisher: AnyPublisher<AuthenticationState<SomeUser>, Never> { get }
    /// The current user, if authenticated
    var user: SomeUser? { get }
}
