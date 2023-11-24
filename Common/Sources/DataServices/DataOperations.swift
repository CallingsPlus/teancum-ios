import Combine
import Foundation

public protocol DataPublisherOperation<Value> {
    associatedtype Value
    var publisher: AnyPublisher<Value, Error> { get }
}

/// An operation which returns a single value. The operation can be invoked using Swift Concurrency or Combine syntax.
public enum SingleValueDataOperation<Value>: DataPublisherOperation {
    case async(() async throws -> Value)
    case publisher(() -> AnyPublisher<Value, Error>)
}

public extension SingleValueDataOperation {
        
    /// Executes the operation using Swift Concurrency
    func async() async throws -> Value {
        switch self {
        case .async(let thunk):
            return try await thunk()
        case .publisher(let thunk):
            for try await value in thunk().values {
                return value
            }
            throw OperationError.noValueEmittedByPublisher
        }
    }
    
    /// Returns a deferred single-value publisher for observing the operation. Execution is deferred until the first subscription occurs.
    var publisher: AnyPublisher<Value, Error> {
        switch self {
        case .async(let thunk):
            Deferred {
                Future { promise in
                    Task {
                        do {
                            promise(.success(try await thunk()))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
        case .publisher(let thunk):
            Deferred {
                thunk()
            }
            .eraseToAnyPublisher()
        }
    }
    
    enum OperationError: Swift.Error {
        case noValueEmittedByPublisher
    }
}

/// An operation which returns a stream values. The operation can be invoked using Swift Concurrency or Combine syntax.
public enum StreamDataOperation<Value>: DataPublisherOperation {
    case stream(() -> AsyncThrowingStream<Value, Error>)
    case publisher(() -> AnyPublisher<Value, Error>)
}

public extension StreamDataOperation where Value == Any {
    static var subscriptions: Set<AnyCancellable> = []
    
    /// Returns an asynchronous stream for the operation.
    var stream: AsyncThrowingStream<Value, Error> {
        get async throws {
            switch self {
            case .stream(let thunk):
                thunk()
            case .publisher(let thunk):
                AsyncThrowingStream { continuation in
                    thunk()
                        .sink { result in
                            if case .failure(let error) = result {
                                continuation.finish(throwing: error)
                            } else {
                                continuation.finish()
                            }
                        } receiveValue: { value in
                            continuation.yield(value)
                        }
                        .store(in: &Self.subscriptions)
                }
            }
        }
    }
}

public extension StreamDataOperation {
    /// Returns a value-stream publisher for observing the operation. Evaluation is deferred until the first subscription occurs.
    var publisher: AnyPublisher<Value, Error> {
        switch self {
        case .stream(let thunk):
            Deferred {
                let subject = PassthroughSubject<Value, Error>()
                Task {
                    do {
                        for try await value in thunk() {
                            subject.send(value)
                        }
                    } catch {
                        subject.send(completion: .failure(error))
                    }
                    subject.send(completion: .finished)
                }
                return subject
            }
            .eraseToAnyPublisher()
        case .publisher(let thunk):
            Deferred {
                thunk()
            }
            .eraseToAnyPublisher()
        }
    }
}
