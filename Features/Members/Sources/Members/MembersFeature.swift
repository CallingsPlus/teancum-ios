import CodeLocation
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

public extension CodeDomain where Self == String {
    static var members: CodeDomain { "ios.callings-plus.members" }
    static var membersImporter: CodeDomain { "ios.callings-plus.members.importer" }
}
