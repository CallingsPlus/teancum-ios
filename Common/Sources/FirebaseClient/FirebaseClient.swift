import Firebase
import FirebaseAuth
import FirebaseFunctions
import Logging

public enum FirebaseClient {
    static let functions = Functions.functions()
    static let authentication = Auth.auth()
    static let firestore = Firestore.firestore()
    
    public static func configure() {
#if DEBUG
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        firestore.settings = settings

        authentication.useEmulator(withHost: "localhost", port: 9099)
        functions.useEmulator(withHost: "http://localhost", port: 5001)
#endif
        
        FirebaseApp.configure()
        LogEvent(.debug, "\(Self.self) configured").log()
    }
    
    /// Returns: ID of the Unit
    public static func createUnit(name: String) async throws -> String {
        let request = [
            "name", name
        ]
        
        let response = try await functions.httpsCallable("units-create").call(request).data as? [String: Any] ?? [:]
        
        // TODO: Throw here if the ID doesn't exist 
        return response["id"] as! String
    }
    
    public static func getUnit(id: String) async throws -> Unit {
        return try await firestore.collection("units").document(id).getDocument(as: Unit.self)
    }
}
