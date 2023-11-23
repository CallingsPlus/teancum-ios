import DataStoreTypes
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct FirebaseUser: Codable {
    @DocumentID public var id: String?
    public var _unit: String?
    public var _role: String?
}

extension FirebaseUser: DataStoreTypes.User {
    public var unit: String? { _unit }    
    public var role: String? { _role }
}
