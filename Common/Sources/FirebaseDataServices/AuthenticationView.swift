import DataServices
import FirebaseAuthUI
//import FirebaseOAuthUI
//import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI
import FirebasePhoneAuthUI
import SwiftUI

public struct FirebaseAuthenticationViewBuilder {
    public init() { }
    public func buildView<SomeAuthenticationStateProviding: AuthenticationStateProviding & FUIAuthDelegate>(authStateProvider: SomeAuthenticationStateProviding) -> some View {
        AuthenticationView(authStateProvider: authStateProvider)
    }
}

struct AuthenticationView<SomeAuthenticationStateProviding: AuthenticationStateProviding & FUIAuthDelegate>: UIViewControllerRepresentable {
    let authStateProvider: SomeAuthenticationStateProviding
    
    init(authStateProvider: SomeAuthenticationStateProviding) {
        self.authStateProvider = authStateProvider
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        context.coordinator.authUI!.authViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(authStateProvider: authStateProvider)
    }
    
    class Coordinator {
        let authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
//            FUIOAuth.appleAuthProvider(),
//            FUIGoogleAuth(authUI: FUIAuth.defaultAuthUI()!),
            FUIEmailAuth(authAuthUI: FUIAuth.defaultAuthUI()!, signInMethod: EmailPasswordAuthSignInMethod, forceSameDevice: false, allowNewEmailAccounts: true, actionCodeSetting: ActionCodeSettings()),
            FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)
        ]
        let authStateProvider: SomeAuthenticationStateProviding
    
        init(authStateProvider: SomeAuthenticationStateProviding) {
            self.authStateProvider = authStateProvider
            authUI?.delegate = authStateProvider
            authUI?.providers = providers
            authUI?.privacyPolicyURL = URL(string: "https://callingsplus.com/privacy-policy")
            authUI?.tosurl = URL(string: "https://callingsplus.com/terms-of-service")
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(authStateProvider: FirebaseAuthenticationStateProvider(firebaseAPI: FirebaseAPI(environment: .dev)))
    }
}
