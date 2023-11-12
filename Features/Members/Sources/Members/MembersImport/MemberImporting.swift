import Combine

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

#if DEBUG
// Mocks & Preview Support
public struct MockMemberImporting: MemberImporting {
    public var importPublisher: AnyPublisher<MemberImportResult, Error>
    
    public init<SomePublisher: Publisher<MemberImportResult, Error>>(_ importPublisher: SomePublisher = Empty()) {
        self.importPublisher = importPublisher.eraseToAnyPublisher()
    }
    
    public func importMembers(fromText text: String) -> AnyPublisher<MemberImportResult, Error> {
        importPublisher
    }
}
public extension MemberImporting {
    typealias Mock = MockMemberImporting
}

public struct MockMemberImportingDependency: MemberImportingDependency {
    public var memberImporter: MemberImporting
    
    public init(memberImporter: MemberImporting) {
        self.memberImporter = memberImporter
    }
    
    public init(_ mockPublisher: some Publisher<MemberImportResult, Error> = Empty()) {
        memberImporter = MockMemberImporting(mockPublisher)
    }
}
public extension MemberImportingDependency {
    typealias Mock = MockMemberImportingDependency
}
#endif
