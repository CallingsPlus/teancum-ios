import Combine

public protocol MemberProviding {
    var members: [Member] { get }
    var membersPublisher: AnyPublisher<[Member], Never> { get }
    
    /// Loads members from a datasource
    /// - Returns: An observable list of members
    func observeMembersList() -> AnyPublisher<[Member], Error>
}

public protocol MemberProvidingDependency {
    var memberProvider: MemberProviding { get }
}

#if DEBUG
// Mocks & Preview Support
public class MockMemberProviding: MemberProviding {
    public var members: [Member] = []
    public var membersPublisher: AnyPublisher<[Member], Never>
    
    public init(
        members: [Member] = [],
        membersPublisher: AnyPublisher<[Member], Never> = Empty().eraseToAnyPublisher(),
        observeMembersListPublisher: AnyPublisher<[Member], Error> = Empty().eraseToAnyPublisher()
    ) {
        self.members = members
        self.membersPublisher = membersPublisher
        self.observeMembersListPublisher = observeMembersListPublisher
    }
    
    public var observeMembersListPublisher: AnyPublisher<[Member], Error>
    public var observeMembersListCallCount = 0
    public func observeMembersList() -> AnyPublisher<[Member], Error> {
        observeMembersListCallCount += 1
        return observeMembersListPublisher
    }
}

public extension MemberProviding {
    typealias Mock = MockMemberProviding
}

public struct MockMemberProvidingDependency: MemberProvidingDependency {
    public var memberProvider: MemberProviding
    
    public init(memberProvider: MemberProviding) {
        self.memberProvider = memberProvider
    }
    
    public init(
        members: [Member] = [],
        membersPublisher: AnyPublisher<[Member], Never> = Empty().eraseToAnyPublisher(),
        observeMembersListPublisher: AnyPublisher<[Member], Error> = Empty().eraseToAnyPublisher()
    ) {
        memberProvider = MockMemberProviding(members: members, membersPublisher: membersPublisher, observeMembersListPublisher: observeMembersListPublisher)
    }
}

public extension MemberProvidingDependency {
    typealias Mock = MockMemberProvidingDependency
}
#endif
