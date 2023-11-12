import Combine
import FirebaseClient
import Foundation
import Members

public typealias MembersRepositoryDependencies = FirebaseClientDependency

class MembersRepository {
    let dependencies: MembersRepositoryDependencies
    let unitID: String
    let membersSubject: CurrentValueSubject<[Members.Member], Never>
    
    init(dependencies: MembersRepositoryDependencies, unitID: String, defaultValue: [Members.Member] = []) {
        self.dependencies = dependencies
        self.unitID = unitID
        self.membersSubject = .init(defaultValue)
    }
}

extension MembersRepository: MemberProviding {
    var members: [Members.Member] { membersSubject.value }
    var membersPublisher: AnyPublisher<[Members.Member], Never> { membersSubject.eraseToAnyPublisher() }
    
    func observeMembersList() -> AnyPublisher<[Members.Member], Error> {
        let responseSubject = PassthroughSubject<[Members.Member], Error>()
        Task {
            do {
                for try await members in try await dependencies.firebaseClient.getUnitMembers(unitID: unitID) {
                    let members = members.map { member in
                        // TODO: Reconcile record ID paradigms UUID <-> String
                        Members.Member(id: UUID(), firstName: member.firstName ?? "", lastName: member.lastName ?? "", isHidden: false, hasGivenPermission: false)
                    }
                    responseSubject.send(members)
                    membersSubject.send(members)
                }
                responseSubject.send(completion: .finished)
            } catch {
                responseSubject.send(completion: .failure(error))
            }
        }
        return responseSubject.eraseToAnyPublisher()
    }
}

extension MembersRepository: MemberEditing {
    func save(member: Members.Member) -> AnyPublisher<Void, Error> {
        Empty().eraseToAnyPublisher() // TODO: Connect with firebase query
    }
}

extension MembersRepository: MemberImporting {
    func importMembers(fromText text: String) -> AnyPublisher<Members.MemberImportResult, Error> {
        let responseSubject = PassthroughSubject<Members.MemberImportResult, Error>()
        Task {
            do {
                let resultString = try await dependencies.firebaseClient.membersImport(from: text)
                responseSubject.send(MemberImportResult(membersImported: 0)) // TODO: Connect with firebase query
                responseSubject.send(completion: .finished)
            } catch {
                responseSubject.send(completion: .failure(error))
            }
        }
        return responseSubject.eraseToAnyPublisher()
    }
}
