import SwiftUI
import VSM

public typealias MembersListViewDependencies = MembersListViewStateDependencies

struct MembersListView<Dependencies: MembersListViewDependencies>: View {
    let dependencies: Dependencies
    @ViewState var state: MembersListViewState = .initialized(MembersListViewState.LoaderModel())
    
    var body: some View {
        switch state {
        case .initialized(let loaderModel):
            HStack { }
                .onAppear {
                    $state.observe(loaderModel.loadMembersList(dependencies: dependencies))
                }
        case .loading:
            ProgressView("Loading Members...")
        case .loaded(let loadedModel):
            Table(loadedModel.members) {
                TableColumn("Last Name", value: \.lastName)
                TableColumn("First Name", value: \.firstName)
                TableColumn("Email", value: \.displayEmail)
                TableColumn("Phone", value: \.displayPhone)
                TableColumn("Notes", value: \.displayNotes)
                TableColumn("Hidden", value: \.displayIsHidden)
            }
        case .error(let errorModel):
            VStack {
                Text("💣 Oops! Something went wrong while loading the list of members.")
                Button("Retry") {
                    $state.observe(errorModel.retry(dependencies: dependencies))
                }
            }
        }
    }
}

struct MembersListView_Previews: PreviewProvider {
    struct PreviewError: Error { }
    
    static let members: [Member] = [
        .init(id: UUID(), firstName: "John", lastName: "Doe", email: "bobsmith@test.com", phone: "555-555-5555", notes: "Foo", isHidden: true, hasGivenPermission: true),
        .init(id: UUID(), firstName: "Jane", lastName: "Smith", isHidden: false, hasGivenPermission: false)
    ]
    
    static let error = PreviewError()
    
    static var previews: some View {
        MembersListView(dependencies: .Mock())
            .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
            .previewDisplayName("Loading")
        MembersListView(dependencies: .Mock(Just(members).setFailureType(to: Error.self)))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
            .previewDisplayName("Loaded")
        MembersListView(dependencies: .Mock(Fail(outputType: [Member].self, failure: error)))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
            .previewDisplayName("Error")
    }
}


//TODO: Add this to VSM 😅
import Combine

extension StateObserving {
    /// Renders the states emitted by the publisher on the view.
    /// - Parameter statePublisher: The view state publisher to be observed for rendering the current view state
    func observe(_ statePublisher: some Publisher<State, Never>) {
        observe(statePublisher.eraseToAnyPublisher())
    }
}
