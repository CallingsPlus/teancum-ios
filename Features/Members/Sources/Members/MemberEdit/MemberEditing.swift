import Combine

public protocol MemberEditing {
    
    /// Saves a member's information
    /// - Returns: An observable save operation
    func save(member: Member) -> AnyPublisher<Void, Error>
}

public protocol MemberEditingDependency {
    var memberEditor: MemberEditing { get }
}

#if DEBUG
// Mocks & Preview Support
public struct MockMemberEditing<SomeSavePublisher: Publisher<Void, Error>>: MemberEditing {
    public let mockPublisher: SomeSavePublisher
    
    public init(_ mockPublisher: SomeSavePublisher = Empty()) {
        self.mockPublisher = mockPublisher
    }
    
    public func save(member: Member) -> AnyPublisher<Void, Error> {
        mockPublisher.eraseToAnyPublisher()
    }
}
public extension MemberEditing {
    typealias Mock = MockMemberEditing
}

public struct MockMemberEditingDependency: MemberEditingDependency {
    public var memberEditor: MemberEditing
    
    public init(memberEditor: MemberEditing) {
        self.memberEditor = memberEditor
    }
    
    public init(_ mockPublisher: some Publisher<Void, Error> = Empty()) {
        memberEditor = MockMemberEditing(mockPublisher)
    }
}
public extension MemberEditingDependency {
    typealias Mock = MockMemberEditingDependency
}
#endif
