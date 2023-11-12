import Logging
import Members
import MembersMockConfig
import SwiftUI

@main
struct MembersApp: App {
    
    init() {
        ConsoleLogger.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MembersFeature
                .mocked(members: [
                    .init(id: UUID(), firstName: "John", lastName: "Doe", email: "bobsmith@test.com", phone: "555-555-5555", notes: "Foo", isHidden: true, hasGivenPermission: true),
                    .init(id: UUID(), firstName: "Jane", lastName: "Smith", isHidden: false, hasGivenPermission: false)
                ])
                .membersListView
        }
    }
}
