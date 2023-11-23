import Combine
import DataStoreTypes
import Foundation

public class FirebaseMembersRepository: Repository<[FirebaseMember]> {
    public init(firebaseAPI: FirebaseAPI, unitID: String) {
        super.init(defaultValue: nil) {
            firebaseAPI.getUnitMembers(unitID: unitID)
        }
    }
}
