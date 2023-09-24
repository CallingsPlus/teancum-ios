import Combine
import Members

class MembersRepository: MemberProviding {
    func observeMembersList() -> AnyPublisher<[Member], Error> {
        Empty().eraseToAnyPublisher() // TOOD: Connect with firebase query
    }
}
