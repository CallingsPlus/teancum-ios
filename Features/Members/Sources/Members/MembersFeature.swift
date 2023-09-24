import SwiftUI

public typealias MembersFeatureDependencies = MembersListViewDependencies

public struct MembersFeature<Dependencies: MembersFeatureDependencies> {
    let dependencies: Dependencies
    
    public var membersListView: some View {
        MembersListView(dependencies: dependencies)
    }
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
