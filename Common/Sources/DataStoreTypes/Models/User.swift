import Combine

public protocol User {
    var id: String? { get }
    var unit: String? { get }
    var role: String? { get }
}

public protocol CurrentUserProviding {
    var value: User? { get }
    var publisher: AnyPublisher<User?, Never> { get }
}

public protocol CurrentUserProvidingDependency {
    var currentUser: CurrentUserProviding { get }
}
