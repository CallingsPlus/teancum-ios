import Combine
import ErrorHandling
import Logging
import VSM

public typealias MembersImportViewStateDependencies = MemberImportingDependency

enum MembersImportViewState {
    case initialized(ImporterModel)
    case importing
    case importError(ErrorModel)
    case importComplete(recordCount: Int)
    
    struct ImporterModel {
        func beginImport(dependencies: MembersImportViewStateDependencies, rawText: String?) -> AnyPublisher<MembersImportViewState, Never> {
            guard let rawText, !rawText.isEmpty else {
                let errorModel = ErrorModel(errorMessage: "💣 Oops! Your clipboard was empty. Please copy the member information and try again.") {
                    Just(MembersImportViewState.initialized(self)).eraseToAnyPublisher()
                }
                return Just(.importError(errorModel)).eraseToAnyPublisher()
            }
            
            let importPublisher = dependencies.memberImporter
                .importMembers(fromText: rawText)
                .map { importResult in
                    if importResult.membersImported == 0 {
                        return MembersImportViewState.importError(.init(errorMessage: "No members were imported.", retry: nil))
                    }
                    return .importComplete(recordCount: importResult.membersImported)
                }
                .catch { error in
                    error.handle("Showing error view", in: .members)
                    let errorModel = ErrorModel(errorMessage: "💣 Oops! Something went wrong. Please try again.") {
                        beginImport(dependencies: dependencies, rawText: rawText).eraseToAnyPublisher()
                    }
                    return Just<MembersImportViewState>(.importError(errorModel))
                }
            
            return Just(MembersImportViewState.importing)
                .merge(with: importPublisher)
                .eraseToAnyPublisher()
        }
    }
    
    struct ErrorModel {
        let errorMessage: String
        let retry: (() -> AnyPublisher<MembersImportViewState, Never>)?
    }
}
