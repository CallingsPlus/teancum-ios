import Combine

public protocol User {
    var id: String? { get }
    var unit: String? { get }
    var role: String? { get }
}

public protocol CurrentUserProviding {
    var currentUser: User? { get }
    var publisher: AnyPublisher<User?, Never> { get }
}

public protocol CurrentUserProvidingDependency {
    var currentUserProvider: CurrentUserProviding { get }
}
