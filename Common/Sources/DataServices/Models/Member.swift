public protocol Member: Identifiable {
    var id: String { get }
    var firstName: String { get set }
    var lastName: String { get set }
    var email: String? { get set }
    var phone: String? { get set }
    var notes: String? { get set }
    var isHidden: Bool { get set }
    var hasGivenPermission: Bool { get set }
}

#if DEBUG
public struct MockMember: Member {
    public var id: String
    public var firstName: String
    public var lastName: String
    public var email: String?
    public var phone: String?
    public var notes: String?
    public var isHidden: Bool
    public var hasGivenPermission: Bool
    
    public init(id: String, firstName: String, lastName: String, email: String? = nil, phone: String? = nil, notes: String? = nil, isHidden: Bool, hasGivenPermission: Bool) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.notes = notes
        self.isHidden = isHidden
        self.hasGivenPermission = hasGivenPermission
    }
}
#endif
