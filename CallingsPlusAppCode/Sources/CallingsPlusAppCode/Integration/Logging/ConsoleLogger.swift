import CodeLocation
import Combine
import Logging
import OSLog

extension CodeDomain where Self == String {
    static var consoleLogger: CodeDomain { "ios.callings-plus.console-logger" }
}

class ConsoleLogger {
    private static var subscription: AnyCancellable?
    private static var loggers: [String: Logger] = [:]
    
    static func configure() {
        guard subscription == nil else { return }
        subscription = LogEvent.publisher
            .sink(receiveValue: logEvent)
        logDebug("\(Self.self) configured", in: .consoleLogger)
    }
    
    static func reset() {
        subscription = nil
        loggers = [:]
    }
    
    private static func logEvent(_ event: LogEvent) {
        let logger = logger(for: event.location.module)
        var eventData = event.data
        eventData[Constants.logLocationKey] = "\(event.location.module)/\(event.location.file):\(event.location.line)"
        let message = "\(event.level.emoji) \(event.message)\n\t"
            + eventData.map { key, value in "\(key): \(value)" }
                .sorted()
                .joined(separator: "\n\t")
        
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
    
    private static func logger(for module: String) -> Logger {
        if let logger = loggers[module] {
            return logger
        }
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: module)
        loggers[module] = logger
        return logger
    }
}

extension ConsoleLogger {
    enum Constants {
        static var logLocationKey = "event.location"
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
