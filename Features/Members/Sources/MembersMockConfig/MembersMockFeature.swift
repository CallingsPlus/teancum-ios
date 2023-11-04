//
//  MembersMockFeature.swift
//  
//
//  Created by Albert Bori on 9/17/23.
//

import Combine
import Foundation
import Members

public struct MockDependencies: MembersFeatureDependencies {
    var members: [Member] = []
    
    public var memberProvider: MemberProviding {
        let mockLoadPublisher = Just(members)
            .setFailureType(to: Error.self)
            .delay(for: 1, scheduler: DispatchQueue.main)
        return MockMemberProviding(mockLoadPublisher)
    }
        
    public var memberEditor: MemberEditing {
        let mockSavePublisher = Just(Void())
            .setFailureType(to: Error.self)
            .delay(for: 1, scheduler: DispatchQueue.main)
        return MockMemberEditing(mockSavePublisher)
    }
    
    public var memberImporter: MemberImporting {
        let mockImportPublisher = Just(MemberImportResult(membersImported: 1))
            .setFailureType(to: Error.self)
            .delay(for: 1, scheduler: DispatchQueue.main)
        return MockMemberImporting(mockImportPublisher)
    }
}

public extension MembersFeature where Dependencies == MockDependencies {
    static func mocked(members: [Member]) -> Self {
        return MembersFeature(dependencies: MockDependencies(members: members))
    }
}
