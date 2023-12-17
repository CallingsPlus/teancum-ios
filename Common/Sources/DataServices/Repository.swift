import Combine

// MARK: - LoadableRepository

/// Provides a default implementation for a repository object.
/// This class accepts a loader type and handles the state management and observable value persistence.
open class Repository<Value>: ValueProviding {
    @Published public var state: ValueState<Value>
    public var statePublisher: AnyPublisher<ValueState<Value>, Never> { $state.eraseToAnyPublisher() }
    private var loader: () -> any DataPublisherOperation<Value>
    private var loadingSubscription: AnyCancellable?
    
    public init(defaultValue: Value?, loader: @escaping () -> any DataPublisherOperation<Value>) {
        self.loader = loader
        self.state = .initialized(defaultValue: defaultValue)
    }
    
    public func load() -> AnyPublisher<ValueState<Value>, Never> {
        guard loadingSubscription == nil else { return $state.eraseToAnyPublisher() }
        state = .loading(currentValue: value)
        loadingSubscription = loader()
            .publisher
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let failure) = completion {
                    self.state = .loadingError(failure, currentValue: self.value)
                }
            }, receiveValue: { [weak self] newValue in
                guard let self else { return }
                self.state = .loaded(oldValue: newValue, newValue: newValue)
            })
        
        return $state.eraseToAnyPublisher()
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
        loader: @escaping () -> any DataPublisherOperation<Value>,
        saver: @escaping (Value) -> any DataPublisherOperation<Value>
    ) {
        self.save = saver
        super.init(defaultValue: defaultValue, loader: loader)
    }
    
    public func save(_ mutatedValue: Value) -> AnyPublisher<ValueState<Value>, Never> {
        guard savingSubscription == nil else { return $state.eraseToAnyPublisher() }
        savingSubscription = save(mutatedValue)
            .publisher
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let failure) = completion {
                    self.state = .loadingError(failure, currentValue: self.value)
                }
            }, receiveValue: { [weak self] newValue in
                guard let self else { return }
                self.state = .loaded(oldValue: newValue, newValue: newValue)
            })
        
        return $state.eraseToAnyPublisher()
    }
}
