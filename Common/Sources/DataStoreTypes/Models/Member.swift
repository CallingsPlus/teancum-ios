import Combine

// MARK: - Members

public protocol Member {
    var id: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var email: String? { get }
    var phone: String? { get }
}

public protocol MemberProviding {
    var value: [Member] { get }
    var publisher: AnyPublisher<[Member], Never> { get }
    
    /// Loads members from a datasource
    /// - Returns: An observable list of members
    func observe() -> AnyPublisher<[Member], Error>
}

public protocol MemberProvidingDependency {
    var members: MemberProviding { get }
}

// MARK: - MemberImporting

public struct MemberImportResult: Decodable {
    var membersImported: Int
    
    public init(membersImported: Int) {
        self.membersImported = membersImported
    }
}

/// Takes a raw string of information and attempts to find member information. Emits that information as a stream of status updates
public protocol MemberImporting {
    /// Examines the raw data to find importable member records.
    /// - Parameter fromText: Raw member record data (preferably in some sort of recognizable format)
    func importMembers(fromText text: String) -> AnyPublisher<MemberImportResult, Error>
}

public protocol MemberImportingDependency {
    var memberImporter: MemberImporting { get }
}

// MARK: - MemberEditing

public protocol MemberEditing {
    
    /// Saves a member's information
    /// - Returns: An observable save operation
    func save(member: Member) -> AnyPublisher<Void, Error>
}

public protocol MemberEditingDependency {
    var memberEditor: MemberEditing { get }
}
