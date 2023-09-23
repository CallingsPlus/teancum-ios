import SwiftUI

public typealias MembersFeatureDependencies = Any

public struct MembersFeature<Dependencies: MembersFeatureDependencies> {
    let dependencies: Dependencies
    
    public var membersListView: some View {
        MembersListView(dependencies: dependencies)
    }
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
