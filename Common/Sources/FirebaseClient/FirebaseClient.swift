import CodeLocation
import Firebase
import FirebaseAuth
import FirebaseFunctions
import Logging

extension CodeDomain where Self == String {
    static var firebaseClient: CodeDomain { "ios.callings-plus.firebase-client" }
}

public enum FirebaseClient {
    static let functions = Functions.functions()
    static let authentication = Auth.auth()
    static let firestore = Firestore.firestore()
    
    public static func configure() {
        FirebaseApp.configure()
        
#if DEBUG
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        firestore.settings = settings
        
        authentication.useEmulator(withHost: "localhost", port: 9099)
        functions.useEmulator(withHost: "http://localhost", port: 5001)
#endif
        
        logDebug("\(Self.self) configured", in: .firebaseClient)
    }
    
    // MARK: - Units
    
    /// - Returns: ID of the Unit
    public static func createUnit(name: String) async throws -> String {
        let request = [
            "name": name
        ]
        
        _ = try await functions.httpsCallable("units-create").call(request).data as? [String: Any] ?? [:]
        
        return try await forceClaimRefreshForUnitChange()
    }
    
    public static func getUnit(id: String) async throws -> Unit {
        return try await firestore.collection("units").document(id).getDocument(as: Unit.self)
    }
    
    public static func getUnitInviteToken() async throws -> String {
        let response = try await functions.httpsCallable("units-invite").call().data as? [String: Any] ?? [:]
        
        // TODO: Throw here if the token doesn't exist
        return response["token"] as! String
    }
    
    public static func getUnitUsers(unitID: String) async throws -> AsyncThrowingStream<[User], Error> {
        return firestore.collection("users")
            .whereFilter(.whereField("_unit", isEqualTo: unitID))
            .order(by: "displayName")
            .addSnapshotListener()
    }
    
    /// - Returns: ID of the Unit
    public static func joinUnit(with inviteToken: String) async throws -> String {
        let request = [
            "token": inviteToken
        ]
        
        _ = try await functions.httpsCallable("units-join").call(request).data as? [String: Any] ?? [:]
        
        return try await forceClaimRefreshForUnitChange()
    }
    
    // MARK: - Members
    
    public static func membersImport(from memberData: String) async throws -> String {
        try await functions.httpsCallable("members-import").call(memberData)
    }
    
    public static func memberCreate(from member: Member, forUnitWithID unitID: String) async throws -> Member {
        var member = member
        member.id = try firestore.document("units/\(unitID)").collection("members").addDocument(from: member).documentID
        
        return member
    }
    
    public static func getUnitMembers(unitID: String) async throws -> AsyncThrowingStream<[Member], Error> {
        return firestore.collection("units/\(unitID)/members")
            .order(by: "lastName")
            .order(by: "firstName")
            .addSnapshotListener()
    }
    
    // MARK: - Prayers
    
    public static func recordPrayer(on date: Date, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
        let prayer = [
            "date": date,
        ] as [String : Any]
        
        try await firestore.collection("units/\(unitID)/members/\(memberID)/prayers").addDocument(data: prayer)
    }
    
    public static func update(prayerStatistic: PrayerStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
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
    
    public static func recordTalk(on date: Date, topic: String?, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
        let talk = [
            "date": date,
            "topic": topic ?? ""
        ] as [String : Any]
        
        try await firestore.collection("units/\(unitID)/members/\(memberID)/talks").addDocument(data: talk)
    }
    
    public static func update(talkStatistic: TalkStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) async throws {
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
    private static func forceClaimRefreshForUnitChange() async throws -> String {
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
