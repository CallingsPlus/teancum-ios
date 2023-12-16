import Combine
import Foundation

/// A protocol that defines the API for interacting with the members data.
public protocol MembersService<SomeMember> {
    associatedtype SomeMember: Member
    
    /// Imports members from member data.
    /// - Parameter memberData: The member data to import.
    /// - Returns: A `SingleValueDataOperation` that emits a success message.
    func membersImport(fromMemberData memberData: String) -> SingleValueDataOperation<String>
    
    /// Creates a new member for a unit.
    /// - Parameters:
    ///   - member: The member to create.
    ///   - unitID: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits the created member data.
    func createMember(_ member: SomeMember, forUnitWithID unitID: String) -> SingleValueDataOperation<SomeMember>
    
    /// Retrieves the members in a unit.
    /// - Parameter unitID: The ID of the unit.
    /// - Returns: A `StreamDataOperation` that emits an array of members and continues to observe for future changes.
    func getUnitMembers(unitID: String) -> StreamDataOperation<[SomeMember]>
        
    /// Instantiates a new, blank member object used for creating a new member
    /// - Returns: An initialized member instance
    func initializeMember() -> SomeMember
}

/// A protocol that defines the API for interacting with the members data.
public protocol MembersServiceDependency<SomeMembersService> {
    associatedtype SomeMembersService: MembersService
    /// A protocol that defines the API for interacting with the members data.
    var membersService: SomeMembersService { get }
}

#if DEBUG
public class MockMembersService<SomeMember: Member>: MembersService {
    public var membersImportCalled = false
    public var membersImportCallCount = 0
    public var membersImportClosure: ((String) -> SingleValueDataOperation<String>)?
    public var membersImportParameter: String?
    
    public var createMemberCalled = false
    public var createMemberCallCount = 0
    public var createMemberClosure: ((SomeMember, String) -> SingleValueDataOperation<SomeMember>)?
    public var createMemberParameters: (SomeMember, String)?
    
    public var getUnitMembersCalled = false
    public var getUnitMembersCallCount = 0
    public var getUnitMembersClosure: ((String) -> StreamDataOperation<[SomeMember]>)?
    public var getUnitMembersParameter: String?
    
    public var initializeMemberCalled = false
    public var initializeMemberCallCount = 0
    public var initializeMemberClosure: (() -> SomeMember)?
    
    public init() {}
    
    public func membersImport(fromMemberData memberData: String) -> SingleValueDataOperation<String> {
        membersImportCalled = true
        membersImportCallCount += 1
        membersImportParameter = memberData
        return membersImportClosure?(memberData) ?? SingleValueDataOperation<String>.async({ "" })
    }
    
    public func createMember(_ member: SomeMember, forUnitWithID unitID: String) -> SingleValueDataOperation<SomeMember> {
        createMemberCalled = true
        createMemberCallCount += 1
        createMemberParameters = (member, unitID)
        return createMemberClosure?(member, unitID) ?? SingleValueDataOperation<SomeMember>.async({ member })
    }
    
    public func getUnitMembers(unitID: String) -> StreamDataOperation<[SomeMember]> {
        getUnitMembersCalled = true
        getUnitMembersCallCount += 1
        getUnitMembersParameter = unitID
        return getUnitMembersClosure?(unitID) ?? StreamDataOperation<[SomeMember]>.publisher({ Empty().eraseToAnyPublisher() })
    }
    
    public func initializeMember() -> SomeMember {
        initializeMemberCalled = true
        initializeMemberCallCount += 1
        return initializeMemberClosure!()
    }
}

public extension MembersService {
    typealias Mock = MockMembersService
}

public extension MembersServiceDependency {
    typealias Mock = MockMembersServiceDependency
}

public class MockMembersServiceDependency<SomeMembersService: MembersService<MockMember>>: MembersServiceDependency {
    public var membersService: SomeMembersService
    
    public init(membersService: SomeMembersService) {
        self.membersService = membersService
    }
    
    public init() where SomeMembersService == MockMembersService<MockMember> {
        self.membersService = .Mock()
    }
}
#endif
