import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct User: Codable {
    @DocumentID public var id: String?
    
    public let hasCompletedOnboarding: Bool
    public let isStripeConnected: Bool
    public let balance: Int?
}
