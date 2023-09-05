import SwiftUI
import FirebaseClient

struct UnauthenticatedView: View {
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
            AuthenticationViewProvider().authenticationView()
                .ignoresSafeArea(.container, edges: .bottom)
        }

    }
}

struct UnauthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        UnauthenticatedView()
    }
}
