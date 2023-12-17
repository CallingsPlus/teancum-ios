import Combine

/// The possible states of authentication.
public enum AuthenticationState<SomeUser: User> {
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
    associatedtype SomeUser: User
    /// Current authentication state
    var state: AuthenticationState<SomeUser> { get }
    /// Publisher for authentication state changes
    var statePublisher: AnyPublisher<AuthenticationState<SomeUser>, Never> { get }
    /// The current user, if authenticated
    var user: SomeUser? { get }
}

public extension AuthenticationStateProviding {
    var user: SomeUser? { state.user }
}

/// A protocol for providing authentication state.
public protocol AuthenticationStateProvidingDependency {
    associatedtype SomeAuthenticationStateProviding: AuthenticationStateProviding
    /// A protocol for providing authentication state.
    var authenticationStateProvider: SomeAuthenticationStateProviding { get }
}

#if DEBUG

public extension AuthenticationStateProviding {
    typealias Mock = MockAuthenticationStateProviding
}

public class MockAuthenticationStateProviding<SomeUser: User>: AuthenticationStateProviding {
    public var state: AuthenticationState<SomeUser>
    public var statePublisher: AnyPublisher<AuthenticationState<SomeUser>, Never>
    public var user: SomeUser?
    
    public convenience init() {
        self.init(state: .signedOut, statePublisher: Empty().eraseToAnyPublisher())
    }
    
    public init(state: AuthenticationState<SomeUser>, statePublisher: AnyPublisher<AuthenticationState<SomeUser>, Never>, user: SomeUser? = nil) {
        self.state = state
        self.statePublisher = statePublisher
        self.user = user
    }
}

#endif
