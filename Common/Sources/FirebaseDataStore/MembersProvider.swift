import Combine
import DataStoreTypes
import Foundation

public class MembersProvider {
    let firebaseAPI: FirebaseAPI
    let unitID: String
    let membersSubject: CurrentValueSubject<[DataStoreTypes.Member], Never>
    
    public init(firebaseAPI: FirebaseAPI, unitID: String, defaultValue: [DataStoreTypes.Member] = []) {
        self.firebaseAPI = firebaseAPI
        self.unitID = unitID
        self.membersSubject = .init(defaultValue)
    }
}

extension MembersProvider: MemberProviding {
    public var value: [DataStoreTypes.Member] { membersSubject.value }
    public var publisher: AnyPublisher<[DataStoreTypes.Member], Never> { membersSubject.eraseToAnyPublisher() }
    
    public func observe() -> AnyPublisher<[DataStoreTypes.Member], Error> {
        let responseSubject = PassthroughSubject<[DataStoreTypes.Member], Error>()
        Task {
            do {
                for try await members in try await firebaseAPI.getUnitMembers(unitID: unitID) {
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

extension MembersProvider: MemberEditing {
    public func save(member: DataStoreTypes.Member) -> AnyPublisher<Void, Error> {
        Empty().eraseToAnyPublisher() // TODO: Connect with firebase query
    }
}

extension MembersProvider: MemberImporting {
    public func importMembers(fromText text: String) -> AnyPublisher<DataStoreTypes.MemberImportResult, Error> {
        let responseSubject = PassthroughSubject<DataStoreTypes.MemberImportResult, Error>()
        Task {
            do {
                let resultString = try await firebaseAPI.membersImport(from: text)
                responseSubject.send(MemberImportResult(membersImported: 0)) // TODO: Connect with firebase query
                responseSubject.send(completion: .finished)
            } catch {
                responseSubject.send(completion: .failure(error))
            }
        }
        return responseSubject.eraseToAnyPublisher()
    }
}
