import Combine
import FirebaseClient
import Members
import SwiftUI

public struct ProdDependencies: MembersFeatureDependencies {
    public var memberEditor: MemberEditing
    public var memberProvider: MemberProviding
    
    init() {
        let membersRepository = MembersRepository()
        memberEditor = membersRepository
        memberProvider = membersRepository
    }
}

public extension MembersFeature where Dependencies == ProdDependencies {
    static var prod: Self {
        MembersFeature(dependencies: ProdDependencies())
    }
}
