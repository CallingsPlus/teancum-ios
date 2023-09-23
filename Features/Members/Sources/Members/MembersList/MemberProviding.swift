import Combine

public protocol MemberProviding {
    
    /// Loads members from a datasource
    /// - Returns: An observable list of members
    func observeMembersList() -> AnyPublisher<[Member], Error>
}

public protocol MemberProvidingDependency {
    var memberProvider: MemberProviding { get }
}

#if DEBUG
// Mocks & Preview Support
public struct MockMemberProviding<SomeMemberPublisher: Publisher<[Member], Error>>: MemberProviding {
    public let mockPublisher: SomeMemberPublisher
    
    public init(_ mockPublisher: SomeMemberPublisher = Empty()) {
        self.mockPublisher = mockPublisher
    }
    
    public func observeMembersList() -> AnyPublisher<[Member], Error> {
        mockPublisher.eraseToAnyPublisher()
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
    
    public init<SomeMemberPublisher: Publisher<[Member], Error>>(_ mockPublisher: SomeMemberPublisher = Empty()) {
        memberProvider = MockMemberProviding(mockPublisher)
    }
}
public extension MemberProvidingDependency {
    typealias Mock = MockMemberProvidingDependency
}
#endif
