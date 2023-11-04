import Combine
import ErrorHandling
import Logging

public typealias MembersListViewStateDependencies = MemberProvidingDependency

enum MembersListViewState {
    case initialized(LoaderModel)
    case loading
    case loaded(LoadedModel)
    case error(ErrorModel)
    
    struct LoaderModel {
        func loadMembersList(dependencies: MemberProvidingDependency) -> some Publisher<MembersListViewState, Never> {
            logDebug("Loading members...", in: .members)
            let memberPublisher = dependencies.memberProvider
                .observeMembersList()
                .map { members in
                    logDebug("Members loaded", in: .members, data: ["members.count": members.count])
                    return MembersListViewState.loaded(LoadedModel(members: members))
                }
                .catch { error in
                    error.handle("Error view shown", in: .members)
                    return Just(MembersListViewState.error(ErrorModel(message: "")))
                }
            return Just(.loading)
                .merge(with: memberPublisher)
        }
    }
    
    struct LoadedModel {
        let members: [Member]
    }
    
    struct ErrorModel {
        let message: String
        
        func retry(dependencies: MemberProvidingDependency) -> some Publisher<MembersListViewState, Never> {
            LoaderModel().loadMembersList(dependencies: dependencies)
        }
    }
}