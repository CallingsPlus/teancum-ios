import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Unit: Codable {
    @DocumentID public var id: String?
    public var name: String?
}
