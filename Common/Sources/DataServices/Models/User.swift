import Combine

/// Represents a user.
/// For the current user, use the ``AuthenticationStateProviding`` protocol.
public protocol User {
    var id: String? { get }
    var unit: String? { get }
    var role: String? { get }
}
