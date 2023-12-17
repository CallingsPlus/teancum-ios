import SwiftUI
import VSM

public typealias MainTabViewDependencies = MembersListViewDependencies

public struct MainTabView<Dependencies: MainTabViewDependencies>: View {
    let dependencies: Dependencies
    @ViewState var state: MainTabViewState = .loaded
    @State var selectedTab: Int = 1
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            Text("Members")
                .tabItem { MembersListView(dependencies: dependencies) }
                .tag(1)
            Text("Tab Content 2")
                .tabItem { Text("Tab Label 2") }
                .tag(2)
        }
    }
}

enum MainTabViewState {
    case loaded
}
