import Combine
import FirebaseClient
import Members
import SwiftUI

public struct MembersProdDependencies: MembersFeatureDependencies {
    public typealias ExternalDependencies = MembersRepositoryDependencies
    
    public var memberEditor: MemberEditing
    public var memberProvider: MemberProviding
    public var memberImporter: MemberImporting
    
    init(dependencies externalDependencies: ExternalDependencies, unitID: String) {
        let membersRepository = MembersRepository(dependencies: externalDependencies, unitID: unitID)
        memberEditor = membersRepository
        memberProvider = membersRepository
        memberImporter = membersRepository
    }
}

public extension MembersFeature where Dependencies == MembersProdDependencies {
    static func prod(dependencies: MembersProdDependencies.ExternalDependencies, unitID: String) -> Self {
        let internalDependencies = MembersProdDependencies(dependencies: dependencies, unitID: unitID)
        return MembersFeature(dependencies: internalDependencies)
    }
}
