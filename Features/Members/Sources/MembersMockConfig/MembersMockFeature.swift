//
//  MembersMockFeature.swift
//  
//
//  Created by Albert Bori on 9/17/23.
//

import Members

public struct MockDependencies: MembersFeatureDependencies {
    //TODO: injectable I/O
}

public extension MembersFeature where Dependencies == MockDependencies {
    static var mocked: Self {
        MembersFeature(dependencies: MockDependencies())
    }
}
