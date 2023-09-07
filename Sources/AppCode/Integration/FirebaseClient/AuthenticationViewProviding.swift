import FirebaseClient
import SwiftUI

// MARK: Dependency Definition

protocol AuthenticationViewProvidingDependency {
    associatedtype SomeAuthenticationViewProviding: ViewProviding
    var authenticationViewProvider: SomeAuthenticationViewProviding { get }
}

// MARK: Conformance

extension AuthenticationViewProvider: ViewProviding { }
