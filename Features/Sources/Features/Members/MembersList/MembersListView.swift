import CodeLocation
import DataServices
import Logging
import SwiftUI
import VSM

public extension CodeDomain where Self == String {
    static var members: CodeDomain { "ios.callings-plus.members" }
    static var membersImporter: CodeDomain { "ios.callings-plus.members.importer" }
}

public typealias MembersListViewDependencies = MembersListViewStateDependencies
                                             & MemberEditViewDependencies
                                             & MembersImportViewDependencies
                                             & MembersServiceDependency // Used in this file to create a new member instance

struct MembersListView<Dependencies: MembersListViewDependencies>: View {
    let dependencies: Dependencies
    @ViewState var state: MembersListViewState<Dependencies> = .initialized(MembersListViewState<Dependencies>.LoaderModel())
    @State var selectedMemberId: Dependencies.SomeMembersService.SomeMember.ID?
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
                    // Converts an id binding into a member binding by Id (for working easily with `.popover(item:...)`
                    let memberBinding: Binding<Dependencies.SomeMembersService.SomeMember?> = $selectedMemberId.mapped { memberId in
                        loadedModel.members.first(where: { $0.id == memberId })
                    } from: { memberId, member in
                        member?.id
                    }

                    Table(loadedModel.members, selection: $selectedMemberId) {
                        TableColumn("Name", value: \.fullNameReversed)
                        TableColumn("Email", value: \.displayEmail)
                        TableColumn("Phone", value: \.displayPhone)
                        TableColumn("Notes", value: \.displayNotes)
                        TableColumn("Hidden", value: \.displayIsHidden)
                    }
                    .popover(item: memberBinding) { member in
                        memberEditView(for: member, from: loadedModel)
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
            #if os(macOS)
            // Mac Catalyst: Listen for clipboard changes (indicative of a paste action)
            .onPasteCommand(
                of: [.html, .text, .tabSeparatedText, .commaSeparatedText],
                perform: { providers in
                    logDebug("Paste action detected", in: .membersImporter)
                    grabClipboardContent()
                })
            #endif
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
    
    func memberEditView(for member: Dependencies.SomeMembersService.SomeMember?, from loadedModel: MembersListViewState<Dependencies>.LoadedModel) -> some View {
        let member = member ?? dependencies.membersService.initializeMember()
        return MemberEditView(dependencies: dependencies, member: member)
            .padding()
    }
    
    func grabClipboardContent() {
        let text = Clipboard.getClipboardString()
        logDebug("Launching member importer from clipboard text...", in: .membersImporter, data: ["clipboard_text": text ?? "nil"])
        clipboardText = text
    }
}

#if DEBUG
import Combine

private enum Preview {
    static var members: [MockMember] = [
        .init(id: UUID().uuidString, firstName: "John", lastName: "Doe", email: "bobsmith@test.com", phone: "555-555-5555", notes: "Foo", isHidden: true, hasGivenPermission: true),
        .init(id: UUID().uuidString, firstName: "Jane", lastName: "Smith", isHidden: false, hasGivenPermission: false)
    ]
    
    struct Dependencies: MembersListViewDependencies {
        var membersService: MembersService.Mock<MockMember>
        var authenticationStateProvider: AuthenticationStateProviding.Mock<MockUser>
        
        init(members: some Publisher<[MockMember], Error>) {
            membersService = .init()
            membersService.getUnitMembersClosure = { _ in .publisher({ members.eraseToAnyPublisher() }) }
            authenticationStateProvider = .init()
        }
    }
    
    struct Fail: Error { }
}

#endif

#Preview("Loading") {
    MembersListView(dependencies: Preview.Dependencies(members: Empty()))
        .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
}

#Preview("Loaded") {
    MembersListView(dependencies: Preview.Dependencies(members: Just(Preview.members).setFailureType(to: Error.self)))
        .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
}

#Preview("Error") {
    MembersListView(dependencies: Preview.Dependencies(members: Fail(outputType: [MockMember].self, failure: Preview.Fail() as Error)))
        .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
}
