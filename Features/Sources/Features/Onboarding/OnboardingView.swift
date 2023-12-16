import SwiftUI

public typealias OnboardingViewDependencies = AuthenticationViewProviding

public struct OnboardingView<Dependencies: OnboardingViewDependencies>: View {
    let dependencies: Dependencies
    @State var isShowingAuthentication = false
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            Text("Let's magnify your calling!")
                .font(Font.largeTitle)
                .fontWeight(.semibold)
            Text("Sign up to get started")
                .font(Font.title3)
            
            Button("Sign Up") {
                isShowingAuthentication.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Spacer()
            
            HStack {
                Text("Already have an account?")
            
                Button("Sign In") {
                    isShowingAuthentication.toggle()
                }
            }
            .font(.caption)
            .padding()
        }
        .sheet(isPresented: $isShowingAuthentication) {
            isShowingAuthentication = false
        } content: {
            dependencies.authenticationView
                .ignoresSafeArea(.container, edges: .bottom)
        }

    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(dependencies: .Mock(authenticationView: Text("Mock Authentication View")))
    }
}
