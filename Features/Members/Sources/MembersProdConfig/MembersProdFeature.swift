import FirebaseClient
import Members
import SwiftUI

public struct ProdDependencies: MembersFeatureDependencies {

}

public extension MembersFeature where Dependencies == ProdDependencies {
    static var prod: Self {
        MembersFeature(dependencies: ProdDependencies())
    }
}
