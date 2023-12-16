import Combine
import Foundation

/// A protocol that defines the API for interacting with the user data.
public protocol UserService {
    associatedtype SomeUser: User
    
    /// Retrieves a user by their ID.
    /// - Parameter userID: The ID of the user.
    /// - Returns: A `StreamDataOperation` that emits the user data and continues to observe for future changes.
    func getUser(byID userID: String) -> StreamDataOperation<SomeUser>
}

/// A protocol that defines the API for interacting with the user data.
public protocol UserServiceDependency {
    associatedtype SomeUserService: UserService
    /// A protocol that defines the API for interacting with the user data.
    var userService: SomeUserService { get }
}
