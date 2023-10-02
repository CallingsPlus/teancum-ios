import Combine
import ExtendedFoundation
import Foundation
import VSM

public typealias MemberEditViewStateDependencies = MemberEditingDependency

enum MemberEditViewState {
    
    case editing(EditingModel)
    case saving
    
    enum SaveResult {
        case none
        case success
        case error(Error)
    }
    
    struct EditingModel: MutatingCopyable {
        private(set) var saveResult: SaveResult = .none
        
        func save(dependencies: MemberEditViewStateDependencies, member: Member) -> some Publisher<MemberEditViewState, Never> {
            guard !member.firstName.isBlank else {
                return Just(.editing(self.copy(mutating: { $0.saveResult = .error(ValidationError.firstNameEmpty) })))
                    .eraseToAnyPublisher()
            }
            guard !member.lastName.isBlank else {
                return Just(.editing(self.copy(mutating: { $0.saveResult = .error(ValidationError.lastNameEmpty) })))
                    .eraseToAnyPublisher()
            }
            let savePublisher = dependencies.memberEditor.save(member: member)
                .map { _ in
                    MemberEditViewState.editing(self.copy(mutating: { $0.saveResult = .success }))
                }
                .catch { error in
                    Just(MemberEditViewState.editing(self.copy(mutating: { $0.saveResult = .error(error) })))
                }
            let saveCompletePublisher = Just(MemberEditViewState.editing(self.copy(mutating: { $0.saveResult = .none })))
                .delay(for: 3, scheduler: DispatchQueue.main)
            return Just(.saving)
                .merge(with: savePublisher)
                .merge(with: saveCompletePublisher)
                .eraseToAnyPublisher()
        }
    }
    
    enum ValidationError: Error {
        case firstNameEmpty
        case lastNameEmpty
    }
}
