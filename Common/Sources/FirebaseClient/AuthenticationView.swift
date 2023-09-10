import FirebaseAuthUI
//import FirebaseOAuthUI
//import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI
import FirebasePhoneAuthUI
import SwiftUI

public struct AuthenticationViewProvider {
    public init() { }
    
    public var view: some View {
        AuthenticationView()
    }
}

struct AuthenticationView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        context.coordinator.authUI!.authViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        let authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
//            FUIOAuth.appleAuthProvider(),
//            FUIGoogleAuth(authUI: FUIAuth.defaultAuthUI()!),
            FUIEmailAuth(authAuthUI: FUIAuth.defaultAuthUI()!, signInMethod: EmailPasswordAuthSignInMethod, forceSameDevice: false, allowNewEmailAccounts: true, actionCodeSetting: ActionCodeSettings()),
            FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)
        ]
    
        init() {
            authUI?.delegate = SessionManager.shared
            authUI?.providers = providers
            authUI?.privacyPolicyURL = URL(string: "https://callingsplus.com/privacy-policy")
            authUI?.tosurl = URL(string: "https://callingsplus.com/terms-of-service")
        }
        
    }
    
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}

