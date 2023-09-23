import Combine
import FirebaseClient
import Members
import SwiftUI

public struct ProdDependencies: MembersFeatureDependencies {
    public var memberProvider: MemberProviding = MembersRepository()
}

public extension MembersFeature where Dependencies == ProdDependencies {
    static var prod: Self {
        MembersFeature(dependencies: ProdDependencies())
    }
}
