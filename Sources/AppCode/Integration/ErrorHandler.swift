import Combine
import ErrorHandling
import Foundation
import Logging

class ErrorHandler {
    private static var subscription: AnyCancellable?
    
    static func configure() {
        guard subscription == nil else { return }
        
        subscription = HandleableError.publisher
            .sink { error in
                if error.isIgnorable && error.severity.logLevel != .debug { return }
                LogEvent(error.severity.logLevel, "\(error.rootError)", error.data).log()
            }
        LogEvent(.debug, "\(Self.self) configured").log()
    }
    
    static func reset() {
        subscription = nil
    }
}

private extension HandleableError {
    var isIgnorable: Bool {
        let errorCode = (rootError as NSError).code
        switch errorCode {
        case NSURLErrorNetworkConnectionLost,
            NSURLErrorCancelled,
            NSURLErrorCannotFindHost,
            NSURLErrorTimedOut,
            NSURLErrorDNSLookupFailed,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorSecureConnectionFailed,
            NSURLErrorCannotConnectToHost:
            return true
        default:
            return false
        }
    }
}

extension HandleableError.Severity {
    var logLevel: LogEvent.Level {
        switch self {
        case .error:
            return .error
        case .warning:
            return .warning
        case .debug:
            return .debug
        }
    }
}
