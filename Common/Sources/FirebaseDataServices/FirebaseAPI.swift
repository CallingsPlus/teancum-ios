import CodeLocation
import DataServices
import Firebase
import FirebaseAuth
import FirebaseFunctions
import Logging

extension CodeDomain where Self == String {
    static var firebaseDataServices: CodeDomain { "ios.callings-plus.firebase-client" }
}

public class FirebaseAPI: MembersService, PrayersService, TalksService, UnitsService, UserService {
    public enum Environment {
        case dev
        case staging
        case prod
    }
    
    private let functions = Functions.functions()
    private let authentication = Auth.auth()
    private let firestore = Firestore.firestore()
    
    public init(environment: Environment) {
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
        
        logDebug("\(FirebaseAPI.self) configured", in: .FirebaseDataServices)
    }
    
    // MARK: - User
    
    public func getUser(byID userID: String) -> StreamDataOperation<FirebaseUser> {
        .stream {
            AsyncThrowingStream<FirebaseUser, Error> { continuation in
                self.firestore
                    .document("users/\(userID)")
                    .addSnapshotListener { snapshot, error in
                        guard let snapshot else {
                            return continuation.finish(throwing: FirebaseError.unableToQuery(message: "Unable to get user with ID: \(userID)"))
                        }
                        do {
                            let user = try snapshot.data(as: FirebaseUser.self)
                            continuation.yield(user)
                        } catch {
                            continuation.finish(throwing: error)
                        }
                    }
            }
        }
    }
    
    // MARK: - Units
    
    public func createUnit(name: String) -> SingleValueDataOperation<String> {
        .async {
            let request = [
                "name": name
            ]
            
            _ = try await self.functions.httpsCallable("units-create").call(request).data as? [String: Any] ?? [:]
            
            return try await self.forceClaimRefreshForUnitChange()
        }
    }
    
    public func getUnit(id: String) -> SingleValueDataOperation<FirebaseUnit> {
        .async {
            try await self.firestore.collection("units").document(id).getDocument(as: FirebaseUnit.self)
        }
    }
    
    public func getUnitInviteToken() -> SingleValueDataOperation<String> {
        .async {
            let response = try await self.functions.httpsCallable("units-invite").call().data as? [String: Any] ?? [:]
            
            guard let token = response["token"] as? String else {
                throw FirebaseAPIError.missingToken.withContext(in: .firebaseDataServices)
            }
            return token
        }
    }
    
    public func getUnitUsers(unitID: String) -> StreamDataOperation<[FirebaseUser]> {
        .stream {
            self.firestore.collection("users")
                .whereFilter(.whereField("_unit", isEqualTo: unitID))
                .order(by: "displayName")
                .addSnapshotListener()
        }
    }
    
    public func joinUnit(withInviteToken inviteToken: String) -> SingleValueDataOperation<String> {
        .async {
            let request = ["token": inviteToken]
            _ = try await self.functions.httpsCallable("units-join").call(request).data as? [String: Any] ?? [:]
            return try await self.forceClaimRefreshForUnitChange()
        }
    }
    
    // MARK: - Members
    
    public func membersImport(fromMemberData memberData: String) -> SingleValueDataOperation<String> {
        .async {
            try await self.functions.httpsCallable("members-import").call(memberData)
        }
    }
    
    public func createMember(_ member: FirebaseMember, forUnitWithID unitID: String) -> SingleValueDataOperation<FirebaseMember> {
        .async {
            var member = member
            member.id = try self.firestore
                .document("units/\(unitID)")
                .collection("members")
                .addDocument(from: member)
                .documentID
            return member
        }
    }
    
    public func getUnitMembers(unitID: String) -> StreamDataOperation<[FirebaseMember]> {
        .stream {
            self.firestore.collection("units/\(unitID)/members")
                .order(by: "lastName")
                .order(by: "firstName")
                .addSnapshotListener()
        }
    }
    
    // MARK: - Prayers
    
    public func recordPrayer(onDate date: Date, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            let prayer = [
                "date": date,
            ] as [String : Any]
            
            try await self.firestore.collection("units/\(unitID)/members/\(memberID)/prayers").addDocument(data: prayer)
        }
    }
    
    public func update(prayerStatistic: PrayerStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            let value: FieldValue
            
            switch change {
            case .increment:
                value = .increment(Int64(1))
            case .decrement:
                value = .increment(Int64(-1))
            }
            
            try await self.firestore.document("units/\(unitID)/members/\(memberID)/information/prayerStatistics").updateData([prayerStatistic.rawValue: value])
        }
    }
    
    // MARK: - Talks
    
    public func recordTalk(onDate date: Date, topic: String?, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            let talk = [
                "date": date,
                "topic": topic ?? ""
            ] as [String : Any]
            
            try await self.firestore.collection("units/\(unitID)/members/\(memberID)/talks").addDocument(data: talk)
        }
    }
    
    public func update(talkStatistic: TalkStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            let value: FieldValue
            
            switch change {
            case .increment:
                value = .increment(Int64(1))
            case .decrement:
                value = .increment(Int64(-1))
            }
            
            try await self.firestore.document("units/\(unitID)/members/\(memberID)/information/talkStatistics").updateData([talkStatistic.rawValue: value])
        }
    }
    
    /// Force the token to refresh with the new claim set from the server
    /// - Returns: ID of the Unit
    private func forceClaimRefreshForUnitChange() async throws -> String {
        var unit: String?
        while true {
            logDebug("Trying to refresh token for unit change...", in: .firebaseDataServices)
            let user = try await authentication.currentUser?.getIDTokenResult(forcingRefresh: true)
            if let unitClaim = user?.claims["unit"] as? String {
                unit = unitClaim
                break
            }
        }
        
        // TODO: Throw here if the id doesn't exist
        guard let unit else {
            throw FirebaseAPIError.missingUnit.withContext(in: .firebaseDataServices)
        }
        return unit
    }
    
    enum FirebaseAPIError: Error {
        case missingToken
        case missingUnit
    }
}

public extension FirebaseAPI {
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
