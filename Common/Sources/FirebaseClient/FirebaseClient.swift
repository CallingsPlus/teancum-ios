import CodeLocation
import Firebase
import FirebaseAuth
import FirebaseFunctions
import Logging

extension CodeDomain where Self == String {
    static var firebaseClient: CodeDomain { "ios.callings-plus.firebase-client" }
}

public protocol FirebaseClientDependency {
    var firebaseClient: FirebaseClient { get }
}

public enum FirebaseEnvironment {
    case dev
    case staging
    case prod
}

public class FirebaseClient {
    private let functions = Functions.functions()
    private let authentication = Auth.auth()
    private let firestore = Firestore.firestore()
    
    public init(environment: FirebaseEnvironment) {
        let settings = Firestore.firestore().settings
        switch environment {
        case .dev:
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
            
            authentication.useEmulator(withHost: "localhost", port: 9099)
            functions.useEmulator(withHost: "http://localhost", port: 5001)
        case .staging:
            break // TODO: Configure staging environment
        case .prod:
            break // TODO: Configure production environment
        }
        firestore.settings = settings
        
        logDebug("\(Self.self) configured", in: .firebaseClient)
    }
    
    // MARK: - User
    
    /// Get's the current user by ID
    /// - Parameter userID: The current user's ID
    /// - Returns: A stream of user updates
    public func getUser(byID userID: String) -> AsyncThrowingStream<User, Error> {
        AsyncThrowingStream<User, Error> { continuation in
            firestore
                .document("users/\(userID)")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot else {
                        return continuation.finish(throwing: FirebaseError.unableToQuery(message: "Unable to get user with ID: \(userID)"))
                    }
                    do {
                        let user = try snapshot.data(as: User.self)
                        continuation.yield(user)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
        }
    }
    
    // MARK: - Units
    
    /// - Returns: ID of the Unit
    public func createUnit(name: String) async throws -> String {
        let request = [
            "name": name
        ]
        
        _ = try await functions.httpsCallable("units-create").call(request).data as? [String: Any] ?? [:]
        
        return try await forceClaimRefreshForUnitChange()
    }
    
    public func getUnit(id: String) async throws -> Unit {
        return try await firestore.collection("units").document(id).getDocument(as: Unit.self)
    }
    
    public func getUnitInviteToken() async throws -> String {
        let response = try await functions.httpsCallable("units-invite").call().data as? [String: Any] ?? [:]
        
        // TODO: Throw here if the token doesn't exist
        return response["token"] as! String
    }
    
    public func getUnitUsers(unitID: String) async throws -> AsyncThrowingStream<[User], Error> {
        return firestore.collection("users")
            .whereFilter(.whereField("_unit", isEqualTo: unitID))
            .order(by: "displayName")
            .addSnapshotListener()
    }
    
    /// - Returns: ID of the Unit
    public func joinUnit(with inviteToken: String) async throws -> String {
        let request = [
            "token": inviteToken
        ]
        
        _ = try await functions.httpsCallable("units-join").call(request).data as? [String: Any] ?? [:]
        
        return try await forceClaimRefreshForUnitChange()
    }
    
    // MARK: - Members
    
    public func membersImport(from memberData: String) async throws -> String {
        try await functions.httpsCallable("members-import").call(memberData)
    }
    
    public func memberCreate(from member: Member, forUnitWithID unitID: String) async throws -> Member {
        var member = member
        member.id = try firestore.document("units/\(unitID)").collection("members").addDocument(from: member).documentID
        
        return member
    }
    
    public func getUnitMembers(unitID: String) async throws -> AsyncThrowingStream<[Member], Error> {
        return firestore.collection("units/\(unitID)/members")
            .order(by: "lastName")
            .order(by: "firstName")
            .addSnapshotListener()
    }
    
    // MARK: - Prayers
    
    public func recordPrayer(on date: Date, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
        let prayer = [
            "date": date,
        ] as [String : Any]
        
        try await firestore.collection("units/\(unitID)/members/\(memberID)/prayers").addDocument(data: prayer)
    }
    
    public func update(prayerStatistic: PrayerStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
        let value: FieldValue
        
        switch change {
        case .increment:
            value = .increment(Int64(1))
        case .decrement:
            value = .increment(Int64(-1))
        }
        
        try await firestore.document("units/\(unitID)/members/\(memberID)/information/prayerStatistics").updateData([prayerStatistic.rawValue: value])
    }
    
    // MARK: - Talks
    
    public func recordTalk(on date: Date, topic: String?, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
        let talk = [
            "date": date,
            "topic": topic ?? ""
        ] as [String : Any]
        
        try await firestore.collection("units/\(unitID)/members/\(memberID)/talks").addDocument(data: talk)
    }
    
    public func update(talkStatistic: TalkStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
        let value: FieldValue
        
        switch change {
        case .increment:
            value = .increment(Int64(1))
        case .decrement:
            value = .increment(Int64(-1))
        }
        
        try await firestore.document("units/\(unitID)/members/\(memberID)/information/talkStatistics").updateData([talkStatistic.rawValue: value])
    }
    
    /// Force the token to refresh with the new claim set from the server
    /// - Returns: ID of the Unit
    private func forceClaimRefreshForUnitChange() async throws -> String {
        var unit: String?
        while true {
            print("Trying to refresh token for unit change...")
            let user = try await authentication.currentUser?.getIDTokenResult(forcingRefresh: true)
            if let unitClaim = user?.claims["unit"] as? String {
                unit = unitClaim
                break
            }
        }
        
        // TODO: Throw here if the id doesn't exist
        return unit!
    }
}

public extension FirebaseClient {
    /// Calls firebase's configure for use in app display manager.
    static func configure() {
        FirebaseApp.configure()
    }
}

public enum FirebaseError: Error {
    case unableToQuery(message: String)
}

extension Query {
    func addSnapshotListener<T>(
        includeMetadataChanges: Bool = false
    ) -> AsyncThrowingStream<[T], Error> where T : Decodable {
        .init { continuation in
            let listener = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                } else{
                    continuation.yield(snapshot?.documents
                        .compactMap {
                            do {
                                return try $0.data(as: T.self)
                            } catch {
                                print("🛑 Error \n\(error)")
                                return nil
                            }
                        } ?? [])
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}

public enum ChangeType {
    case increment, decrement
}
