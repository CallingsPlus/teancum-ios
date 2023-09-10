import SwiftUI

protocol AuthenticationViewProvidingDependency {
    associatedtype SomeAuthenticationViewProviding: ViewProviding
    var authenticationViewProvider: SomeAuthenticationViewProviding { get }
}
