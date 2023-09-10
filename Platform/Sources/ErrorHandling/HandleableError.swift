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
    public var location: Location
    private let isLoggableCopy: Bool
    public var rootError: Error { (innerError as? HandleableError)?.innerError ?? innerError }
    
    init(innerError: Error, message: String?, severity: Severity, data: [String: Any], location: Location, isLoggableCopy: Bool = false) {
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
}

extension HandleableError {
    public enum State {
        /// A ``HandleableError`` was created but never acknowledged or handled
        case unhandled
        /// A ``HandleableError`` was acknowledged, but not fully handled. (not ideal)
        case acknowledged(at: Location, message: String?)
        /// A ``HandleableError`` was handled in the best possible manner
        case handled(at: Location, message: String?)
        /// A ``HandleableError`` was intentionally ignored from production logs (will still be visible in debug logs)
        case ignored(at: Location, message: String?)
    }
    
    public enum Severity {
        /// This error disrupted the user's experience or expectations
        case error
        /// This error is a concerning signal, but the user did not immediately notice or is already aware
        case warning
        /// This error is not disruptive and is not actionable. For local debugging only.
        case debug
    }
}

// MARK: Error Handling Streams

public extension HandleableError {
    fileprivate static var subject: PassthroughSubject<HandleableError, Never> = .init()
    /// Publishers errors  to interested observers
    private(set) static var publisher: AnyPublisher<HandleableError, Never> = subject.eraseToAnyPublisher()
}

public extension Error {
    typealias Severity = HandleableError.Severity
    
    @discardableResult
    /// Promotes an error to a ``HandleableError`` type, associating the data (optional) and the call location with the error.
    /// Use this to propagate an error when an error is detected but won't be handled by the code that detected the error.
    func asHandleable(as severity: Severity = .error, message: String? = nil, data: [String: Any] = [:], fileID: String = #fileID, line: Int = #line, column: Int = #column) -> HandleableError {
        HandleableError(
            innerError: self,
            message: message,
            severity: severity,
            data: data,
            location: Location(fileID: fileID, line: line, column: column))
    }
    
    /// Converts the error to a ``HandleableError`` (if not already) and marks it as "handled" and forwards it to ``HandleableError`` subscribers
    func handle(_ message: String? = nil, fileID: String = #fileID, line: Int = #line, column: Int = #column) {
        let handleableError = (self as? HandleableError) ?? self.asHandleable(fileID: fileID, line: line, column: column)
        handleableError.state = .handled(at: .init(fileID: fileID, line: line, column: column), message: message)
        HandleableError.subject.send(handleableError)
    }
    
    /// Converts the error to a ``HandleableError`` (if not already) and marks it as "acknowledged" and forwards it to ``HandleableError`` subscribers
    func acknowledge(_ message: String? = nil, fileID: String = #fileID, line: Int = #line, column: Int = #column) {
        let handleableError = (self as? HandleableError) ?? self.asHandleable(fileID: fileID, line: line, column: column)
        handleableError.state = .acknowledged(at: .init(fileID: fileID, line: line, column: column), message: message)
        HandleableError.subject.send(handleableError)
    }
    
    /// Ignores the error, preventing any downstream error handling if the error is a ``HandleableError`` type.
    func ignore(_ message: String? = nil, fileID: String = #fileID, line: Int = #line, column: Int = #column) {
        let handleableError = (self as? HandleableError) ?? self.asHandleable(fileID: fileID, line: line, column: column)
        handleableError.state = .ignored(at: .init(fileID: fileID, line: line, column: column), message: message)
        HandleableError.subject.send(handleableError)
    }
    
    @discardableResult
    /// Adds metadata to an error (making it ``HandleableError`` if it wasn't already)
    func addData(_ data: [String: Any], fileID: String = #fileID, line: Int = #line, column: Int = #column) -> HandleableError {
        let handleableError = (self as? HandleableError) ?? self.asHandleable(fileID: fileID, line: line, column: column)
        handleableError.data.merge(data) { old, new in new }
        return handleableError
    }
}