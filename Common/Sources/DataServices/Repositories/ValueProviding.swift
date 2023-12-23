import Combine
import Foundation

/// Represents the state of a value.
public enum ValueState<Value> {
    /// The value is initialized with an optional default value.
    case initialized(defaultValue: Value?)
    
    /// The value is currently being loaded with an optional current value.
    case loading(currentValue: Value?, retryCount: Int, nextRetryDate: Date?)
    
    /// The value has been loaded with an old value and a new value.
    case loaded(oldValue: Value?, newValue: Value)
    
    /// An error occurred while loading the value with an optional current value.
    case loadingError(Error, currentValue: Value?)
}

public extension ValueState {
    /// The current value of the state.
    var value: Value? {
        switch self {
        case .initialized(let defaultValue):
            defaultValue
        case .loading(let currentValue, _, _):
            currentValue
        case .loaded(_, let newValue):
            newValue
        case .loadingError(_, let currentValue):
            currentValue
        }
    }
    
    /// The error associated with the state, if any.
    var error: Error? {
        if case .loadingError(let error, _) = self {
            error
        } else {
            nil
        }
    }
}

/// A protocol for providing a value. Usually backed by a stateful repository type.
public protocol ValueProviding<Value> {
    associatedtype Value
    
    /// A publisher that emits the state of the value.
    var statePublisher: AnyPublisher<ValueState<Value>, Never> { get }
    
    /// The current state of the value.
    var state: ValueState<Value> { get }
    
    /// The current value of the state.
    var value: Value? { get }
    
    /// Loads the value and returns a publisher that emits the state.
    func load() -> AnyPublisher<ValueState<Value>, Never>
}

public extension ValueProviding {
    /// The current value of the state.
    var value: Value? { state.value }
}

/// A protocol for providing a mutable value. Usually backed by a stateful repository type.
public protocol MutableValueProviding<Value>: ValueProviding {
    /// Saves the mutated value and returns a publisher that emits the state.
    func save(_ mutatedValue: Value) -> AnyPublisher<ValueState<Value>, Never>
}
