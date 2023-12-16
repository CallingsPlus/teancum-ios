#if DEBUG

import Combine
import DataServices

public class StubAuthenticationStateProvider: AuthenticationStateProviding {
    public var subject: CurrentValueSubject<AuthenticationState<MockUser>, Never>
        
    // MARK: - AuthenticationStateProviding
    
    public lazy var statePublisher: AnyPublisher<AuthenticationState<MockUser>, Never> = subject.eraseToAnyPublisher()
    public var state: AuthenticationState<MockUser> { subject.value }
    
    public init(initialState: AuthenticationState<MockUser> = .signedOut) {
        subject = .init(initialState)
    }
}

#endif
