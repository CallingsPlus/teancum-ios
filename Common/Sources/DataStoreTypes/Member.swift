import Combine

public protocol Member {
    var id: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var email: String? { get }
    var phone: String? { get }
}

public protocol MemberProviding {
    var members: [Member] { get }
    var publisher: AnyPublisher<[Member], Never> { get }
    
    /// Loads members from a datasource
    /// - Returns: An observable list of members
    func observeMembersList() -> AnyPublisher<[Member], Error>
}

public protocol MemberProvidingDependency {
    var memberProvider: MemberProviding { get }
}
