import Combine

public protocol User {
    var id: String? { get }
    var unit: String? { get }
    var role: String? { get }
}

public protocol CurrentUserProviding {
    associatedtype SomeUser: User
    var value: SomeUser? { get }
    var publisher: AnyPublisher<SomeUser?, Never> { get }
}

public protocol CurrentUserProvidingDependency {
    associatedtype SomeCurrentUserProviding: CurrentUserProviding
    var currentUser: SomeCurrentUserProviding { get }
}
