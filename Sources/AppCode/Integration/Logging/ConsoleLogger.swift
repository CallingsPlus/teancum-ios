import Combine
import Logging
import OSLog

class ConsoleLogger {
    private static var subscription: AnyCancellable?
    private static var loggers: [String: Logger] = [:]
    
    static func configure() {
        guard subscription == nil else { return }
        subscription = LogEvent.publisher
            .sink { event in
                let logger = logger(for: event.location.module)
                let message = "\(event.message)\n\(event.location.module)/\(event.location.file):\(event.location.line)"
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
        LogEvent(.debug, "\(Self.self) configured").log()
    }
    
    static func reset() {
        subscription = nil
        loggers = [:]
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
