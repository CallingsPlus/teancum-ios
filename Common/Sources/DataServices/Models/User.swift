/// Represents a user.
/// For the current user, use the ``AuthenticationStateProviding`` protocol.
public protocol User {
    var id: String? { get }
    var unitID: String? { get }
    var role: String? { get }
}

#if DEBUG
public struct MockUser: User {
    public var id: String?
    public var unitID: String?
    public var role: String?
    
    public init(id: String? = nil, unitID: String? = nil, role: String? = nil) {
        self.id = id
        self.unitID = unitID
        self.role = role
    }
}
#endif
