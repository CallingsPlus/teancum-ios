import Combine

// MARK: - LoadableRepository

public class Repository<Value>: ValueProviding {
    @Published public var state: ValueState<Value>
    public var statePublisher: AnyPublisher<ValueState<Value>, Never> { $state.eraseToAnyPublisher() }
    private var loader: any DataPublisherOperation<Value>
    private var loadingSubscription: AnyCancellable?
    
    init(loader: any DataPublisherOperation<Value>, defaultValue: Value?) {
        self.loader = loader
        self.state = .initialized(defaultValue: defaultValue)
    }
    
    public func load() -> AnyPublisher<ValueState<Value>, Never> {
        guard loadingSubscription == nil else { return $state.eraseToAnyPublisher() }
        state = .loading(currentValue: value)
        loadingSubscription = loader
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

public class MutableRepository<Value>: Repository<Value>, MutableValueProviding {
    private var save: (Value) -> any DataPublisherOperation<Value>
    private var savingSubscription: AnyCancellable?
    
    init(loader: any DataPublisherOperation<Value>, defaultValue: Value?, saver: @escaping (Value) -> any DataPublisherOperation<Value>) {
        self.save = saver
        super.init(loader: loader, defaultValue: defaultValue)
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

// MARK: - ValueState

public enum ValueState<Value> {
    case initialized(defaultValue: Value?)
    case loading(currentValue: Value?)
    case loaded(oldValue: Value?, newValue: Value)
    case loadingError(Error, currentValue: Value?)
}

public extension ValueState {
    var value: Value? {
        switch self {
        case .initialized(let defaultValue):
            defaultValue
        case .loading(let currentValue):
            currentValue
        case .loaded(_, let newValue):
            newValue
        case .loadingError(_, let currentValue):
            currentValue
        }
    }
    
    var error: Error? {
        if case .loadingError(let error, _) = self {
            error
        } else {
            nil
        }
    }
}

// MARK: - ValueProviding

public protocol ValueProviding<Value> {
    associatedtype Value
    
    var statePublisher: AnyPublisher<ValueState<Value>, Never> { get }
    var state: ValueState<Value> { get }
    var value: Value? { get }
    var error: Error? { get }
    
    func load() -> AnyPublisher<ValueState<Value>, Never>
}

public extension ValueProviding {
    var value: Value? { state.value }
    var error: Error? { state.error }
}

// MARK: - MutableValueProviding

public protocol MutableValueProviding: ValueProviding {
    func save(_ mutatedValue: Value) -> AnyPublisher<ValueState<Value>, Never>
}
