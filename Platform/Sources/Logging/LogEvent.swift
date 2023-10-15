import CodeLocation
import Combine
import Foundation

public struct LogEvent {
    public let level: Level
    public let message: String
    public let date: Date = Date()
    public fileprivate(set) var data: [String: Any]
    public let location: CodeLocation
    
    init(level: Level, message: String, data: [String : Any], location: CodeLocation) {
        self.level = level
        self.message = message
        self.data = data
        self.location = location
    }
    
    public init(
        level: Level,
        message: String,
        domain: CodeDomain,
        data: [String : Any],
        fileID: String = #fileID,
        function: String = #function,
        line: Int = #line,
        column: Int = #line
    ) {
        self.level = level
        self.message = message
        self.data = data
        self.location = .init(domain: domain, fileID: fileID, function: function, line: line, column: column)
    }
    
    public func addData(_ key: String, _ value: Any) -> LogEvent {
        var copy = self
        copy.data[key] = value
        return copy
    }
    
    public func mergeData(_ newData: [String: Any]) -> LogEvent {
        var copy = self
        copy.data = data.merging(newData, uniquingKeysWith: { old, new in old })
        return copy
    }
}

extension LogEvent {
    public enum Level: Int, Encodable {
        case error = 0
        case warning = 1
        case info = 2
        case debug = 3
    }
}

// MARK: - Global Logging Support

public extension LogEvent {
    private static var subject: PassthroughSubject<LogEvent, Never> = .init()
    /// Publishes log events to interested observers
    static var publisher: some Publisher<LogEvent, Never> { subject }
    
    func log() {
        Self.subject.send(self)
    }
}

// MARK: Static Helper Functions

/// Logs an error message
/// - Parameters:
///   - message: The message describing the event
///   - domain: The domain of the source event (reverse-domain notation e.g. `com.foo.bar`)
///   - data: Additional information to be sent along with the event
public func logError(
    _ message: String,
    in domain: CodeDomain,
    data: [String: Any] = [:],
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line,
    column: Int = #line
) {
    LogEvent(
        level: .error,
        message: message,
        data: data,
        location: .init(domain: domain, fileID: fileID, function: function, line: line, column: column)
    ).log()
}

/// Logs an warning message
/// - Parameters:
///   - message: The message describing the event
///   - domain: The domain of the source event (reverse-domain notation e.g. `com.foo.bar`)
///   - data: Additional information to be sent along with the event
public func logWarning(
    _ message: String,
    in domain: CodeDomain,
    data: [String: Any] = [:],
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line,
    column: Int = #line
) {
    LogEvent(
        level: .warning,
        message: message,
        data: data,
        location: .init(domain: domain, fileID: fileID, function: function, line: line, column: column)
    ).log()
}

/// Logs an info message
/// - Parameters:
///   - message: The message describing the event
///   - domain: The domain of the source event (reverse-domain notation e.g. `com.foo.bar`)
///   - data: Additional information to be sent along with the event
public func logInfo(
    _ message: String,
    in domain: CodeDomain,
    data: [String: Any] = [:],
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line,
    column: Int = #line
) {
    LogEvent(
        level: .info,
        message: message,
        data: data,
        location: .init(domain: domain, fileID: fileID, function: function, line: line, column: column)
    ).log()
}

/// Logs an debug message
/// - Parameters:
///   - message: The message describing the event
///   - domain: The domain of the source event (reverse-domain notation e.g. `com.foo.bar`)
///   - data: Additional information to be sent along with the event
public func logDebug(
    _ message: String,
    in domain: CodeDomain,
    data: [String: Any] = [:],
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line,
    column: Int = #line
) {
    LogEvent(
        level: .debug,
        message: message,
        data: data,
        location: .init(domain: domain, fileID: fileID, function: function, line: line, column: column)
    ).log()
}
