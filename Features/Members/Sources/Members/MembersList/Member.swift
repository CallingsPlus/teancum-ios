import Foundation

public struct Member {
    public var id: UUID
    public var firstName: String
    public var lastName: String
    public var email: String?
    public var phone: String?
    public var notes: String?
    public var isHidden: Bool
    public var hasGivenPermission: Bool
    
    public init() {
        id = UUID()
        firstName = ""
        lastName = ""
        isHidden = false
        hasGivenPermission = false
    }
    
    public init(id: UUID, firstName: String, lastName: String, email: String? = nil, phone: String? = nil, notes: String? = nil, isHidden: Bool, hasGivenPermission: Bool) {
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

extension Member: Identifiable { }

extension Member {
    var fullName: String { firstName + " " + lastName }
    var fullNameReversed: String { lastName + ", " + firstName }
    var displayEmail: String { email ?? "-" }
    var displayPhone: String { formatPhone(phone) ?? "-" }
    var displayNotes: String { notes ?? "-" }
    var displayIsHidden: String { isHidden ? "Yes" : "" }
    
    private func formatPhone(_ phone: String?) -> String? {
        phone?
            .replacing(#/[^\d]/#, with: "")
            .replacing(#/^1?(\d{3})(\d{3})(\d{4})$/#, with: { match in "(\(match.output.1)) \(match.output.2)-\(match.output.3)" })
    }
}
