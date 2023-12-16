import CodeLocation
import Combine
import DataServices
import ErrorHandling
import FirebaseAuth
import FirebaseAuthUI
import Logging

/// A namespace for the authentication state repository.
extension CodeDomain where Self == String {
    static var authenticationStateRepository: CodeDomain { "ios.callings-plus.auth-state-repository" }
}

/// A class for providing authentication state.
public class FirebaseAuthenticationStateProvider: NSObject {
    private var firebaseAPI: FirebaseAPI
    private let auth: Auth = Auth.auth() // Firebase Auth instance
    private var firebaseUserSubscription: AnyCancellable?
        
    @Published public var state: AuthenticationState<FirebaseUser> = .initializing
    
    /// Initializes an instance of `AuthenticationStateProvider`.
    /// - Parameter auth: The `Auth` instance to use for authentication.
    public init(firebaseAPI: FirebaseAPI) {
        self.firebaseAPI = firebaseAPI
        super.init()
        
        // Check if user is already logged in
        if let currentUser = auth.currentUser {
            logDebug("User already logged in.", in: .authenticationStateRepository, data: ["currentUser": currentUser])
            loadFirebaseUser(fromAuthUser: currentUser)
        } else {
            logDebug("User not yet logged in.", in: .authenticationStateRepository)
            state = .signedOut
        }
        
        // Listen for authentication state changes
        auth.addStateDidChangeListener { [weak self] (snapshot, user) in
            guard let self else { return }
            logDebug("Auth state changed", in: .authenticationStateRepository, data: ["snapshot": snapshot, "user": user as Any])
            if let user = user {
                loadFirebaseUser(fromAuthUser: user)
            } else {
                state = .signedOut
            }
        }
    }
    
    /// Loads the actual user information once the auth-user object has been loaded by Firebase's auth engine
    private func loadFirebaseUser(fromAuthUser authUser: FirebaseAuth.User) {
        let maxRetries = 3
        firebaseUserSubscription = firebaseAPI
            .getUser(byID: authUser.uid)
            .publisher
            .retry(maxRetries)
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let failure) = result {
                    self?.state = .error(failure.withContext("Failed to load \(FirebaseUser.self) after \(maxRetries) retries", in: .authenticationStateRepository))
                }
            }, receiveValue: { [weak self] firebaseUser in
                self?.state = .signedIn(firebaseUser, signOut: { [weak self] in self?.signOut() })
            })
    }
    
    private func signOut() {
        do {
            try auth.signOut()
        } catch {
            logError("Failed to sign out", in: .authenticationStateRepository, data: ["error": error])
        }
    }
}

extension FirebaseAuthenticationStateProvider: AuthenticationStateProviding {
    public var statePublisher: AnyPublisher<DataServices.AuthenticationState<FirebaseUser>, Never> { $state.eraseToAnyPublisher() }
}

extension FirebaseAuthenticationStateProvider: FUIAuthDelegate {
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
            loadFirebaseUser(fromAuthUser: authDataResult.user)
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
