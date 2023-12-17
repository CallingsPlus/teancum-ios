import Combine

public extension AsyncStream {
    
    /// Returns an `AnyPublisher` that publishes elements from the `AsyncStream`.
    ///
    /// Calling this function will trigger the underlying async operation to be called immediately.
    ///
    /// - Returns: An `AnyPublisher` that publishes elements from the `AsyncStream`.
    func executeAsPublisher() -> AnyPublisher<Element, Never> {
        let subject = PassthroughSubject<Element, Never>()
        Task.detached {
            for await element in self {
                subject.send(element)
            }
            subject.send(completion: .finished)
        }
        return subject.eraseToAnyPublisher()
    }
}

public extension AsyncThrowingStream {
    
    /// Returns an `AnyPublisher` that publishes elements from the `AsyncThrowingStream`.
    ///
    /// Calling this function will trigger the underlying async operation to be called immediately.
    ///
    /// - Returns: An `AnyPublisher` that publishes elements from the `AsyncThrowingStream`.
    func executeAsPublisher() -> AnyPublisher<Element, Error> {
        let subject = PassthroughSubject<Element, Error>()
        Task.detached {
            do {
                for try await element in self {
                    subject.send(element)
                }
                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
        return subject.eraseToAnyPublisher()
    }
}
