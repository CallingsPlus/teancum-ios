import CodeLocation
import Combine
import ErrorHandling
import FirebaseAuth
import FirebaseAuthUI
import Logging

/// A namespace for the authentication state repository.
public extension CodeDomain where Self == String {
    static var authenticationStateRepository: CodeDomain { "ios.callings-plus.auth-state-repository" }
}

public typealias FirebaseUser = FirebaseAuth.User

/// The possible states of authentication.
public enum AuthenticationState {
    /// User is signed in with a FirebaseUser object and a signOut closure
    case signedIn(FirebaseUser, signOut: () -> Void)
    /// User is signed out
    case signedOut
    
    /// The Firebase user, if in the signedIn state.
    /// Returns nil if in the signedOut state.
    var firebaseUser: FirebaseUser? {
        switch self {
        case .signedIn(let user, _):
            return user
        case .signedOut:
            return nil
        }
    }
}

/// A protocol for providing authentication state.
public protocol AuthenticationStateProviding: FUIAuthDelegate {
    /// Current authentication state
    var authState: AuthenticationState { get }
    /// Publisher for authentication state changes
    var authStatePublisher: AnyPublisher<AuthenticationState, Never> { get }
}

/// A class for providing authentication state.
public class AuthenticationStateProvider: NSObject {
    fileprivate let authStateSubject = CurrentValueSubject<AuthenticationState, Never>(.signedOut) // Subject for authentication state changes
    private let auth: Auth = Auth.auth() // Firebase Auth instance
    
    /// Initializes an instance of `AuthenticationStateProvider`.
    /// - Parameter auth: The `Auth` instance to use for authentication.
    public override init() {
        super.init()
        
        // Check if user is already logged in
        if let currentUser = auth.currentUser {
            logDebug("User already logged in.", in: .authenticationStateRepository, data: ["currentUser": currentUser])
            authStateSubject.value = .signedIn(currentUser, signOut: { [weak self] in self?.signOut() })
        } else {
            logDebug("User not yet logged in.", in: .authenticationStateRepository)
            authStateSubject.value = .signedOut
        }
        
        // Listen for authentication state changes
        auth.addStateDidChangeListener { [weak self, authStateSubject] (snapshot, user) in
            logDebug("Auth state changed", in: .authenticationStateRepository, data: ["snapshot": snapshot, "user": user as Any])
            if let user = user {
                authStateSubject.send(.signedIn(user, signOut: { [weak self] in self?.signOut() }))
            } else {
                authStateSubject.send(.signedOut)
            }
        }
    }
    
    private func signOut() {
        do {
            try auth.signOut()
        } catch {
            logError("Failed to sign out", in: .authenticationStateRepository, data: ["error": error])
        }
    }
}

extension AuthenticationStateProvider: AuthenticationStateProviding {
    public var authState: AuthenticationState { authStateSubject.value } // Current authentication state
    public var authStatePublisher: AnyPublisher<AuthenticationState, Never> { authStateSubject.eraseToAnyPublisher() } // Publisher for authentication state changes
}

extension AuthenticationStateProvider: FUIAuthDelegate {
    /// Called when the user signs in.
    /// - Parameters:
    ///   - authUI: The `FUIAuth` instance.
    ///   - authDataResult: The `AuthDataResult` containing the user's authentication data.
    ///   - error: The error, if any, that occurred during sign in.
    public func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        logDebug("FUIAuthDelegate didSignInWith", in: .authenticationStateRepository, data: ["authDataResult": authDataResult as Any])
        if let error = error {
            error.acknowledge("💣 Failed to log in", in: .authenticationStateRepository)
        } else if let authDataResult = authDataResult {
            authStateSubject.send(.signedIn(authDataResult.user, signOut: { [weak self] in self?.signOut() }))
        }
    }
    
    /// Called when the user finishes an account settings operation.
    /// - Parameters:
    ///   - authUI: The `FUIAuth` instance.
    ///   - operation: The type of account settings operation that was completed.
    ///   - error: The error, if any, that occurred during the operation.
    public func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        logDebug("FUIAuthDelegate didFinish", in: .authenticationStateRepository, data: ["operation": operation])
        if let error = error {
            error.acknowledge("💣 Error signing in", in: .authenticationStateRepository)
        }
    }
}
