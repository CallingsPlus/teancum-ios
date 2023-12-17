import DataServices
import StubDataServices
import SwiftUI

class StubAppDependencies: AppDependencies {
    let stubAPI: StubAPI = .init()
    let stubAuthenticationStateProvider: StubAuthenticationStateProvider = .init()
    
    var authenticationView: some View {
        EmptyView()
    }
    
    var authenticationStateProvider: some AuthenticationStateProviding {
        stubAuthenticationStateProvider
    }
    
    var membersService: some MembersService {
        stubAPI
    }
}
