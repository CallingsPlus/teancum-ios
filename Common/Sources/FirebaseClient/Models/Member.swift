import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Member: Codable {
    @DocumentID public var id: String?
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var phone: String?
}
