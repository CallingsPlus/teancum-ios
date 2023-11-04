import Logging
import SwiftUI
import VSM

public typealias MembersListViewDependencies = MembersListViewStateDependencies
                                             & MemberEditViewDependencies
                                             & MembersImportViewDependencies

struct MembersListView<Dependencies: MembersListViewDependencies>: View {
    let dependencies: Dependencies
    @ViewState var state: MembersListViewState = .initialized(MembersListViewState.LoaderModel())
    @State var selectedMemberId: UUID?
    @State var clipboardText: String?
    
    var body: some View {
        ZStack {
            VStack {
                switch state {
                case .initialized(let loaderModel):
                    HStack { }
                        .onAppear {
                            $state.observe(loaderModel.loadMembersList(dependencies: dependencies))
                        }
                case .loading:
                    ProgressView("Loading Members...")
                case .loaded(let loadedModel):
                    Table(loadedModel.members, selection: $selectedMemberId) {
                        TableColumn("Name", value: \.fullNameReversed)
                        TableColumn("Email", value: \.displayEmail)
                        TableColumn("Phone", value: \.displayPhone)
                        TableColumn("Notes", value: \.displayNotes)
                        TableColumn("Hidden", value: \.displayIsHidden)
                    }
                    .popover(item: $selectedMemberId) { memberId in
                        memberEditView(for: memberId, from: loadedModel)
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
            // Mac Catalyst: Listen for clipboard changes (indicative of a paste action)
            .onPasteCommand(
                of: [.html, .text, .tabSeparatedText, .commaSeparatedText],
                perform: { providers in
                    logDebug("Paste action detected", in: .membersImporter)
                    grabClipboardContent()
                })
            // iOS: Long press for 4 seconds
            .gesture(LongPressGesture(minimumDuration: 4).onEnded { _ in
                logDebug("Long press detected", in: .membersImporter)
                grabClipboardContent()
            })
            
            // Display the importer if the clipboard content is present
            if clipboardText != nil {
                MembersImportView(dependencies: dependencies, clipboardText: $clipboardText)
            }
        }
    }
    
    func memberEditView(for memberId: UUID?, from loadedModel: MembersListViewState.LoadedModel) -> some View {
        let member = loadedModel.members.first(where: { $0.id == memberId }) ?? Member()
        return MemberEditView(dependencies: dependencies, member: member)
            .padding()
    }
    
    func grabClipboardContent() {
        let text = Clipboard.getClipboardString()
        logDebug("Launching member importer from clipboard text...", in: .membersImporter, data: ["clipboard_text": text ?? "nil"])
        clipboardText = text
    }
}

// Required by popover view helper
extension UUID: Identifiable {
    public var id: UUID { self }
}

struct MembersListView_Previews: PreviewProvider {
    struct PreviewError: Error { }
    struct MockDependencies: MembersListViewDependencies {
        var memberProvider: MemberProviding
        var memberEditor: MemberEditing
        var memberImporter: MemberImporting
        
        init(_ mockMemberPublisher: some Publisher<[Member], Error> = Empty()) {
            memberProvider = .Mock(mockMemberPublisher)
            memberEditor = .Mock()
            memberImporter = .Mock()
        }
    }
    
    static let members: [Member] = [
        .init(id: UUID(), firstName: "John", lastName: "Doe", email: "bobsmith@test.com", phone: "555-555-5555", notes: "Foo", isHidden: true, hasGivenPermission: true),
        .init(id: UUID(), firstName: "Jane", lastName: "Smith", isHidden: false, hasGivenPermission: false)
    ]
    
    static let error = PreviewError()
    
    static var previews: some View {
        MembersListView(dependencies: MockDependencies())
            .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
            .previewDisplayName("Loading")
        MembersListView(dependencies: MockDependencies(Just(members).setFailureType(to: Error.self)))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
            .previewDisplayName("Loaded")
        MembersListView(dependencies: MockDependencies(Fail(outputType: [Member].self, failure: error as Error)))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
            .previewDisplayName("Error")
    }
}


//TODO: Add this to VSM 😅 It removes the requirement for erasing publishers for observation
import Combine

extension StateObserving {
    /// Renders the states emitted by the publisher on the view.
    /// - Parameter statePublisher: The view state publisher to be observed for rendering the current view state
    func observe(_ statePublisher: some Publisher<State, Never>) {
        observe(statePublisher.eraseToAnyPublisher())
    }
}
