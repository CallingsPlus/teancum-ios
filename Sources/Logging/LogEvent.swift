import Combine
import Foundation

public struct LogEvent {
    public let level: Level
    public let message: String
    public let date: Date = Date()
    public let data: [String: Any]
    public let location: Location
    
    public init(_ level: Level, _ message: String, _ data: [String: Any] = [:], fileID: String = #fileID, line: Int = #line) {
        self.level = level
        self.message = message
        self.location = .init(fileID: fileID, line: line)
        self.data = data
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

extension LogEvent {
    public struct Location: Encodable {
        public let module: String
        public let file: String
        public let line: Int
        
        init(fileID: String, line: Int) {
            // Convert ModuleName/FileName.fileextension to module and file
            let split = (fileID as NSString).components(separatedBy: "/")
            module = split.count == 2 ? (split.first ?? "unknown") : "unknown"
            file = split.last ?? "unknown"
            self.line = line
        }
    }
}

// MARK: - Global Logging Support

public extension LogEvent {
    fileprivate static var subject: PassthroughSubject<LogEvent, Never> = .init()
    /// Publishes log events to interested observers
    private(set) static var publisher: AnyPublisher<LogEvent, Never> = subject.eraseToAnyPublisher()
}

public extension LogEvent {
    func log() {
        Self.subject.send(self)
    }
}
