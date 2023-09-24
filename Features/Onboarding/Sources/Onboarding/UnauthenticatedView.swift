import SwiftUI

public typealias UnauthenticatedViewDependencies = AuthenticationViewProviding

struct UnauthenticatedView<Dependencies: UnauthenticatedViewDependencies>: View {
    let dependencies: Dependencies
    @State var isShowingAuthentication = false
    
    var body: some View {
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

struct UnauthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        UnauthenticatedView(dependencies: .Mock(authenticationView: Text("Mock Authentication View")))
    }
}
