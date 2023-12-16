import DataServices
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct FirebaseMember: Codable {
    @DocumentID public var _id: String?
    public var firstName: String
    public var lastName: String
    public var email: String?
    public var phone: String?
    public var notes: String?
    public var isHidden: Bool
    public var hasGivenPermission: Bool
}

extension FirebaseMember: DataServices.Member {
    
    public var id: String {
        _id ?? "\(UUID())"
    }
}
