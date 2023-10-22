import Combine
import Members

class MembersRepository: MemberProviding {
    func observeMembersList() -> AnyPublisher<[Member], Error> {
        Empty().eraseToAnyPublisher() // TOOD: Connect with firebase query
    }
}

extension MembersRepository: MemberEditing {
    func save(member: Members.Member) -> AnyPublisher<Void, Error> {
        Empty().eraseToAnyPublisher() // TODO: Connect with firebase query
    }
}
