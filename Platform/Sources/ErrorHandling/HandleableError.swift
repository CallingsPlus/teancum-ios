import CodeLocation
import Combine
import Foundation

public class HandleableError: Error {
    public let innerError: Error
    public let message: String?
    public fileprivate(set) var severity: Severity
    public fileprivate(set) var data: [String: Any]
    public fileprivate(set) var state: State = .unhandled {
        didSet {
            (innerError as? HandleableError)?.state = state
        }
    }
    public var location: CodeLocation
    private let isLoggableCopy: Bool
    public var rootError: Error { (innerError as? HandleableError)?.innerError ?? innerError }
    
    init(innerError: Error, message: String?, severity: Severity, data: [String: Any], location: CodeLocation, isLoggableCopy: Bool = false) {
        self.innerError = innerError
        self.message = message
        self.severity = severity
        self.data = data
        self.location = location
        self.isLoggableCopy = isLoggableCopy
    }
    
    deinit {
        if !isLoggableCopy, case .unhandled = state {
            Self.subject.send(HandleableError(innerError: innerError, message: message, severity: severity, data: data, location: location, isLoggableCopy: true))
        }
    }
    
    /// Adds metadata to the error's data field. Does not overwrite existing key/value pairs.
    /// - Parameters:
    ///   - key: The key for storing the value in the error's data field
    ///   - value: The value to store in the error's data field
    /// - Returns: The mutated error
    @discardableResult
    public func withData(_ key: String, _ value: Any) -> HandleableError {
        guard data.index(forKey: key) == nil else { return self }
        data[key] = value
        return self
    }
    
    /// Adds metadata to the error's data field. Does not overwrite existing key/value pairs.
    /// - Parameter newData: The new data to be merged into the error's data field
    /// - Returns: The mutated error
    @discardableResult
    public func withData(_ newData: [String: Any]) -> HandleableError {
        data.merge(newData) { old, new in old }
        return self
    }
}

extension HandleableError {
    public enum State {
        /// A ``HandleableError`` was created but never acknowledged or handled
        case unhandled
        /// A ``HandleableError`` was acknowledged, but not fully handled. (not ideal)
        case acknowledged(at: CodeLocation, message: String?)
        /// A ``HandleableError`` was handled in the best possible manner
        case handled(at: CodeLocation, message: String?)
        /// A ``HandleableError`` was intentionally ignored from production logs (will still be visible in debug logs)
        case ignored(at: CodeLocation, message: String?)
    }
    
    public enum Severity {
        /// This error caused the application to become unusable or nearly unusable.
        /// Example: An app crash or a non-responsive UI was detected.
        case critical
        /// This error disrupted the user's experience or expectations.
        /// Example: A web service returned a 500 error while loading a view's content.
        case disruptive
        /// This error is a concerning signal, but did not directly disrupt the user's experience or expectations, or it has an easy workaround.
        /// Example: Discovered a memory warning in an area of code.
        case concerning
        /// This error is not disruptive and is not actionable. For local debugging only.
        /// Example: User's device lost internet service during an API call.
        case trivial
    }
}

extension HandleableError {
}

// MARK: Error Handling Streams

public extension HandleableError {
    fileprivate static var subject: PassthroughSubject<HandleableError, Never> = .init()
    /// Publishers errors  to interested observers.
    static var publisher: some Publisher<HandleableError, Never> { subject }
}

public extension Error {
    typealias Severity = HandleableError.Severity
    
    /// Promotes an error to a ``HandleableError`` type, associating the data (optional) and the call location with the error.
    /// Use this to propagate an error when an error is detected but won't be handled by the code that detected the error.
    /// If the error exits the memory scope without being handled, acknowledged, or ignored, it will automatically be published on ``HandleableError/publisher`` as "unhandled".
    /// - Parameters:
    ///   - message: The message to attach to the error
    ///   - domain: The domain of the source error (reverse-domain notation e.g. `com.foo.bar`)
    ///   - severity: The severity of the error. (Default: ``HandleableError/Severity-swift.enum/disruptive``)
    ///   - data: Additional information to be sent along with the error
    /// - Returns: A ``HandleableError`` type
    @discardableResult
    func withContext(
        _ message: String? = nil,
        in domain: CodeDomain,
        severity: Severity = .disruptive,
        data: [String: Any] = [:],
        fileID: String = #fileID,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) -> HandleableError {
        HandleableError(
            innerError: self,
            message: message,
            severity: severity,
            data: data,
            location: CodeLocation(domain: domain, fileID: fileID, function: function, line: line, column: column)
        )
    }
    
    /// Converts the error to a ``HandleableError`` (if not already) and marks it as "handled" and forwards it to ``HandleableError`` subscribers.
    /// - Parameters:
    ///   - message: Reason, method, or purpose for handling this error
    ///   - domain: The domain of the code that is handling this error (reverse-domain notation e.g. `com.foo.bar`)
    @discardableResult
    func handle(_ message: String, in domain: CodeDomain, fileID: String = #fileID, function: String = #function, line: Int = #line, column: Int = #column) -> HandleableError {
        let handleableError = (self as? HandleableError) ?? self.withContext(in: domain, fileID: fileID, function: function, line: line, column: column)
        handleableError.state = .handled(at: .init(domain: domain, fileID: fileID, function: function, line: line, column: column), message: message)
        HandleableError.subject.send(handleableError)
        return handleableError
    }
    
    /// Converts the error to a ``HandleableError`` (if not already) and marks it as "acknowledged" and forwards it to ``HandleableError`` subscribers.
    /// - Parameters:
    ///   - message: Reason, method, or purpose for acknowledging (but not handling) this error
    ///   - domain: The domain of the code that is acknowledging this error (reverse-domain notation e.g. `com.foo.bar`)
    @discardableResult
    func acknowledge(_ message: String, in domain: CodeDomain, fileID: String = #fileID, function: String = #function, line: Int = #line, column: Int = #column) -> HandleableError {
        let handleableError = (self as? HandleableError) ?? self.withContext(in: domain, fileID: fileID, function: function, line: line, column: column)
        handleableError.state = .acknowledged(at: .init(domain: domain, fileID: fileID, function: function, line: line, column: column), message: message)
        HandleableError.subject.send(handleableError)
        return handleableError
    }
    
    /// Converts the error to a ``HandleableError`` (if not already) and marks it as "ignored" and forwards it to ``HandleableError`` subscribers.
    /// Downstream observers determine how ignored errors behave.
    /// - Parameters:
    ///   - message: Reason, method, or purpose for ignoring this error
    ///   - domain: The domain of the code that is ignoring this error (reverse-domain notation e.g. `com.foo.bar`)
    @discardableResult
    func ignore(_ message: String, in domain: CodeDomain, fileID: String = #fileID, function: String = #function, line: Int = #line, column: Int = #column) -> HandleableError{
        let handleableError = (self as? HandleableError) ?? self.withContext(in: domain, fileID: fileID, function: function, line: line, column: column)
        handleableError.state = .ignored(at: .init(domain: domain, fileID: fileID, function: function, line: line, column: column), message: message)
        HandleableError.subject.send(handleableError)
        return handleableError
    }
}
