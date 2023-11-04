import CodeLocation
import Combine
import OSLog

extension CodeDomain where Self == String {
    static var consoleLogger: CodeDomain { "ios.callings-plus.console-logger" }
}

public class ConsoleLogger {
    private static var subscription: AnyCancellable?
    private static var loggers: [LoggerKey: Logger] = [:]
    
    public static func configure() {
        guard subscription == nil else { return }
        subscription = LogEvent.publisher
            .sink(receiveValue: logEvent)
        logDebug("\(Self.self) configured", in: .consoleLogger)
    }
    
    public static func reset() {
        subscription = nil
        loggers = [:]
    }
    
    private static func logEvent(_ event: LogEvent) {
        let logger = logger(forKey: .init(module: event.location.module, domain: event.location.domain))
        let message = "\(event.level.emoji) \(event.message)"
            + "\(event.data.isEmpty ? "" : "\n\t- ")"
            + event.data.map { key, value in "\(key): \(value)" }
                .sorted()
                .joined(separator: "\n\t- ")
            + "\nin \(event.location.module)/\(event.location.file):\(event.location.line)"
        
        switch event.level {
        case .error:
            logger.error("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .info:
            logger.info("\(message)")
        case .debug:
            logger.debug("\(message)")
        }
    }
    
    private static func logger(forKey key: LoggerKey) -> Logger {
        if let logger = loggers[key] {
            return logger
        }
        let logger = Logger(subsystem: key.module, category: key.domain)
        loggers[key] = logger
        return logger
    }
}

extension ConsoleLogger {
    struct LoggerKey: Hashable {
        let module: String
        let domain: String
    }
}

extension LogEvent.Level {
    var emoji: String {
        switch self {
        case .error: return "📕"
        case .warning: return "📙"
        case .info: return "📘"
        case .debug: return "📓"
        }
    }
}
