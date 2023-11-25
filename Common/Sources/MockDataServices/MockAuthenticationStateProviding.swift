import Combine
import DataServices

public class MockAuthenticationStateProviding<SomeUser>: AuthenticationStateProviding {
    public var state: AuthenticationState<SomeUser>
    public var statePublisher: AnyPublisher<AuthenticationState<SomeUser>, Never>
    public var user: SomeUser?
    
    public init(state: AuthenticationState<SomeUser>, statePublisher: AnyPublisher<AuthenticationState<SomeUser>, Never>, user: SomeUser? = nil) {
        self.state = state
        self.statePublisher = statePublisher
        self.user = user
    }
}
