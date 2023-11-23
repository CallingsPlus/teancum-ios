import DataStoreTypes
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct FirebaseUnit: Codable {
    @DocumentID public var id: String?
    public var name: String?
}

extension FirebaseUnit: DataStoreTypes.Unit { }
