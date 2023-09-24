import SwiftUI

/// Provides the authentication view to the onboarding view so that a direct dependency on firebase is not required
public protocol AuthenticationViewProviding {
    associatedtype AuthenticationView: View
    var authenticationView: AuthenticationView { get }
}

#if DEBUG
// Mocks & Preview Support
public struct MockAuthenticationViewProviding<SomeView: View>: AuthenticationViewProviding {
    public var authenticationView: SomeView
}
public extension AuthenticationViewProviding {
    typealias Mock = MockAuthenticationViewProviding
}
#endif
