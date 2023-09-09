import Combine
import ErrorHandling
import Foundation
import FirebaseAuth
import FirebaseAuthUI
import FirebaseFirestore
import Logging

public class SessionManager: NSObject {
    @Published public var state: SessionState = .signedOut
    @Published public var firebaseUser: FirebaseUser?
    @Published public var user: User?
    
    // TODO: Remove singleton and use injection
    public static let shared = SessionManager()
    
    private static var userCollection: String { "users" }
    
    // MARK: - Listeners
    
    private var userProfileListener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }
    
    private let authentication: Auth
    private let firestore: Firestore
    private var subscriptions: Set<AnyCancellable> = []
    
    public override init() {
        self.firestore = Firestore.firestore()
        self.authentication = Auth.auth()
        
        super.init()
        
        updateSessionState(for: authentication.currentUser)
        
        authentication.addStateDidChangeListener { [weak self] authentication, user in
            self?.updateSessionState(for: user)
        }
    }
    
    public func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            error.acknowledge("💣 Unable to sign out")
        }
    }
    
    private func updateSessionState(for user: FirebaseUser?) {
        state = user == nil ? .signedOut : .signedIn
        self.firebaseUser = user

        guard let userID = user?.uid else {
            self.user = nil
            return
        }
        
        let userDocument = "\(Self.userCollection)/\(userID)"
        
        userProfileListener = firestore.document(userDocument).addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                error.acknowledge("💣 Error getting user")
            }
            
            do {
                self?.user = try snapshot?.data(as: User.self)
            } catch {
                error.acknowledge("💣 Error deserializing user")
                self?.user = nil
            }
        }
    }
    
}

public enum SessionError: Error {
    case userNotSignedIn
}

public enum SessionState {
    case signedOut
    case signedIn
}

public typealias FirebaseUser = FirebaseAuth.User

// MARK: - FUIAuthDelegate

extension SessionManager: FUIAuthDelegate {
    
    public func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            error.acknowledge("💣 Failed to log in")
            return
        } else if let authDataResult = authDataResult {
            firebaseUser = authDataResult.user
        }
    }
    
    public func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        if let error = error {
            error.acknowledge("💣 Error signing in")
        }
    }
    
}
