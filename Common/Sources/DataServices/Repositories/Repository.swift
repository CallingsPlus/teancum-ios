import Combine
import Foundation

// MARK: - LoadableRepository

/// Provides a default implementation for a repository object.
/// This class accepts a loader type and handles the state management and observable value persistence.
open class Repository<Value>: ValueProviding {
    @Published fileprivate var _state: ValueState<Value>
    public var state: ValueState<Value> {
        if case .initialized = _state, configuration.loadingStrategy == .onDemand {
            load()
        }
        return _state
    }
    public var statePublisher: AnyPublisher<ValueState<Value>, Never> {
        if case .initialized = _state, configuration.loadingStrategy == .onDemand {
            load()
        }
        return $_state.eraseToAnyPublisher()
    }
    private let configuration: RepositoryConfiguration
    private let loader: () -> any DataPublisherOperation<Value>
    private var loadingSubscription: AnyCancellable?
    
    public init(defaultValue: Value?, configuration: RepositoryConfiguration = .defaults, loader: @escaping () -> any DataPublisherOperation<Value>) {
        self.loader = loader
        _state = .initialized(defaultValue: defaultValue)
        self.configuration = configuration
        if configuration.loadingStrategy == .automatic {
            load()
        }
    }
        
    @discardableResult
    public func load() -> AnyPublisher<ValueState<Value>, Never> {
        load(retryCount: 0, nextRetryDate: nil)
    }
    
    @discardableResult
    private func load(retryCount: Int, nextRetryDate: Date?) -> AnyPublisher<ValueState<Value>, Never> {
        guard loadingSubscription == nil else { return $_state.eraseToAnyPublisher() }
        _state = .loading(currentValue: value, retryCount: retryCount, nextRetryDate: nextRetryDate)
        loadingSubscription = loader()
            .publisher
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let failure) = completion {
                    if !invokeRetryStrategy(retryCount: retryCount) {
                        self._state = .loadingError(failure, currentValue: self.value)
                    }
                }
            }, receiveValue: { [weak self] newValue in
                guard let self else { return }
                self._state = .loaded(oldValue: newValue, newValue: newValue)
            })
        
        return $_state.eraseToAnyPublisher()
    }
    
    private func invokeRetryStrategy(retryCount: Int) -> Bool {
        switch configuration.retryStrategy {
        case .none:
            return false
        case .infinite(let interval):
            if let interval {
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
                    self?.load(retryCount: retryCount + 1, nextRetryDate: Date(timeIntervalSinceNow: TimeInterval(interval)))
                }
            } else {
                load(retryCount: retryCount + 1, nextRetryDate: .now)
            }
            return true
        case .exponentialBackoff:
            let delay: Int = max(0, min(60, (retryCount - 1) ^ 2))
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) { [weak self] in
                self?.load(retryCount: retryCount + 1, nextRetryDate: Date(timeIntervalSinceNow: TimeInterval(delay)))
            }
            return true
        case .maxRetries(let maxRetryCount):
            if retryCount < maxRetryCount {
                load(retryCount: retryCount + 1, nextRetryDate: .now)
                return true
            } else {
                return false
            }
        }
    }
}

// MARK: - MutableRepository

/// Provides a default implementation for a mutable repository object which can load and save a value.
/// This class accepts a loader and saver type and handles the state management and observable value persistence.
open class MutableRepository<Value>: Repository<Value>, MutableValueProviding {
    private var save: (Value) -> any DataPublisherOperation<Value>
    private var savingSubscription: AnyCancellable?
    
    package init(
        defaultValue: Value?,
        configuration: RepositoryConfiguration = .defaults,
        loader: @escaping () -> any DataPublisherOperation<Value>,
        saver: @escaping (Value) -> any DataPublisherOperation<Value>
    ) {
        self.save = saver
        super.init(defaultValue: defaultValue, configuration: configuration, loader: loader)
    }
    
    public func save(_ mutatedValue: Value) -> AnyPublisher<ValueState<Value>, Never> {
        guard savingSubscription == nil else { return $_state.eraseToAnyPublisher() }
        savingSubscription = save(mutatedValue)
            .publisher
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let failure) = completion {
                    self._state = .loadingError(failure, currentValue: self.value)
                }
            }, receiveValue: { [weak self] newValue in
                guard let self else { return }
                self._state = .loaded(oldValue: newValue, newValue: newValue)
            })
        
        return $_state.eraseToAnyPublisher()
    }
}

public struct RepositoryConfiguration {
    public enum LoadingStrategy {
        case none
        case automatic
        case onDemand
    }
    
    public enum RetryStrategy {
        case none
        case infinite(interval: TimeInterval?)
        case exponentialBackoff(maxRetries: Int)
        case maxRetries(Int)
    }
    
    public let loadingStrategy: LoadingStrategy
    public let retryStrategy: RetryStrategy
    
    public static var defaults: RepositoryConfiguration {
        .init(loadingStrategy: .automatic, retryStrategy: .infinite(interval: nil))
    }
    
}
