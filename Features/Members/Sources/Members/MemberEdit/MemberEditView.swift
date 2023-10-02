import Components
import ExtendedFoundation
import SwiftUI
import VSM

public typealias MemberEditViewDependencies = MemberEditViewStateDependencies

struct MemberEditView<Dependencies: MemberEditViewDependencies>: View {
    let dependencies: Dependencies
    @State var member: Member
    @ViewState var state: MemberEditViewState = .editing(MemberEditViewState.EditingModel())
    
    var canSave: Bool {
        !state.isSaving && member.hasGivenPermission
    }

    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("First Name", text: $member.firstName)
                        .disabled(state.isSaving)
                    TextField("Last Name", text: $member.lastName)
                        .disabled(state.isSaving)
                    TextField("Email", text: $member.email.unwrapped(or: ""))
                        .disabled(state.isSaving)
                    TextField("Phone", text: $member.phone.unwrapped(or: ""))
                        .disabled(state.isSaving)
                    TextField("Notes", text: $member.notes.unwrapped(or: ""), axis: .vertical)
                        .disabled(state.isSaving)
                        .lineLimit(2...10)
                }
                Section {
                    Toggle(isOn: $member.isHidden) {
                        Text("Hidden from speaking and prayer assignments")
                    }
                    .disabled(state.isSaving)
                    Toggle(isOn: $member.hasGivenPermission) {
                        Text("Member has authorized the collection and storage of their information within this app")
                    }
                    .disabled(state.isSaving)
                }
                Section {
                    Button("Save") {
                        if case .editing(let editingModel) = state {
                            $state.observe(editingModel.save(dependencies: dependencies, member: member))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!canSave)
                    .overlay(Group {
                        if state.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    })
                }
            }
            statusView()
        }
    }
    
    @ViewBuilder
    func statusView() -> some View {
        if case .editing(let model) = state {
            switch model.saveResult {
            case .error(let error):
                VStack {
                    StatusView(status: .failure, message: (error as CustomStringConvertible).description)
                        .padding()
                    Spacer()
                }
            case .success:
                VStack {
                    StatusView(status: .success, message: "Member information saved.")
                        .padding()
                    Spacer()
                }
            case .none:
                EmptyView()
            }
        }
    }
}

extension MemberEditViewState {
    var isSaving: Bool {
        if case .saving = self {
            return true
        }
        return false
    }
}

extension MemberEditViewState.ValidationError: CustomStringConvertible {
    var description: String {
        switch self {
        case .firstNameEmpty:
            return "First Name is required."
        case .lastNameEmpty:
            return "Last Name is required."
        }
    }
}

struct MemberEditView_Previews: PreviewProvider {
    struct PreviewError: Error { }
    
    static let fullMember = Member(id: UUID(), firstName: "John", lastName: "Doe", email: "bobsmith@test.com", phone: "555-555-5555", notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent eu congue tellus, non lobortis velit. Mauris ut feugiat sapien, euismod semper erat. In ut lacus urna. Suspendisse eu porttitor mauris. Phasellus ultricies placerat elementum. Phasellus tincidunt risus purus, sed tempus quam convallis ut. Suspendisse diam elit, sodales in mi quis, ullamcorper mattis ipsum. Donec sed efficitur sapien. Etiam elementum, purus nec suscipit consequat, mi dui luctus nunc, ut posuere felis neque posuere elit.", isHidden: true, hasGivenPermission: true)
    static let partialMember = Member(id: UUID(), firstName: "Jane", lastName: "Smith", isHidden: false, hasGivenPermission: false)
    static let emptyMember = Member(id: UUID(), firstName: "", lastName: "", isHidden: false, hasGivenPermission: false)
    
    static let error = PreviewError()
    
    static var previews: some View {
        MemberEditView(dependencies: .Mock(), member: fullMember, state: .editing(.init()))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 700))
            .previewDisplayName("Editing - Full")
        MemberEditView(dependencies: .Mock(), member: partialMember, state: .editing(.init()))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 700))
            .previewDisplayName("Editing - Partial")
        MemberEditView(dependencies: .Mock(), member: emptyMember, state: .editing(.init()))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 700))
            .previewDisplayName("Editing - Empty")
        MemberEditView(dependencies: .Mock(), member: fullMember, state: .saving)
            .previewLayout(PreviewLayout.fixed(width: 500, height: 700))
            .previewDisplayName("Saving")
        MemberEditView(dependencies: .Mock(), member: fullMember, state: .editing(.init(saveResult: .success)))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 700))
            .previewDisplayName("Saved")
        MemberEditView(dependencies: .Mock(), member: fullMember, state: .editing(.init(saveResult: .error(MemberEditViewState.ValidationError.firstNameEmpty))))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 700))
            .previewDisplayName("Missing First Name")
        MemberEditView(dependencies: .Mock(), member: fullMember, state: .editing(.init(saveResult: .error(MemberEditViewState.ValidationError.lastNameEmpty))))
            .previewLayout(PreviewLayout.fixed(width: 500, height: 700))
            .previewDisplayName("Missing Last Name")
    }
}
