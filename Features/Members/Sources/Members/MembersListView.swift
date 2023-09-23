import SwiftUI

typealias MembersListViewDependencies = Any

struct MembersListView<Dependencies: MembersListViewDependencies>: View {
    let dependencies: Dependencies
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MembersListView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Foo")
//        MembersListView(dependencies: .Mock(...))
    }
}
