import Members
import MembersMockConfig
import SwiftUI

@main
struct MembersApp: App {
    var body: some Scene {
        WindowGroup {
            MembersFeature.mocked.membersListView
        }
    }
}
