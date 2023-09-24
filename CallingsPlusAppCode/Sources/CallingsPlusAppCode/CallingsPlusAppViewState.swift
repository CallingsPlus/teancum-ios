import Combine
import Foundation

enum CallingsPlusAppViewState {
    case initialized(LoaderModel)
    case loading
    case loaded(LoadedModel)
    
    struct LoaderModel {
        func load() -> AnyPublisher<CallingsPlusAppViewState, Never> {
            Just(.loading)
                // TODO: Run Startup task system (auth token refresh, remote config, etc)
                .merge(with: Just(.loaded(LoadedModel(dependencies: AppDependencies()))))
                .eraseToAnyPublisher()
        }
    }
    
    struct LoadedModel {
        var dependencies: AppDependencies
    }
}
