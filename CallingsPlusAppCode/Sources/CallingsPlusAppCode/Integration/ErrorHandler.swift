import CodeLocation
import Combine
import ErrorHandling
import Foundation
import Logging

extension CodeDomain where Self == String {
    static var errorHandler: CodeDomain { "ios.callings-plus.error-handler" }
}

class ErrorHandler {
    private static var subscription: AnyCancellable?
    
    static func configure() {
        guard subscription == nil else { return }
        subscription = HandleableError.publisher
            .sink(receiveValue: handleError)
        logDebug("\(Self.self) configured", in: .errorHandler)
    }
    
    static func reset() {
        subscription = nil
    }
    
    /// Converts the error information to a log event and logs it according to severity and handler status
    private static func handleError(_ error: HandleableError) {
        var errorData = error.data
        errorData[Constants.errorTypeKey] = "\(type(of: error.rootError))"
        errorData[Constants.errorMessageKey] = error.message
        errorData[Constants.errorLocationkey] = "\(error.location.module)/\(error.location.file):\(error.location.line):\(error.location.column)"
        errorData[Constants.errorSeveritykey] = "\(error.severity)"
        
        var stack = [String]()
        var stackError = error.innerError as? HandleableError
        while let error = stackError {
            stack.append("\(error.message ?? "") at \(error.location.module)/\(error.location.file):\(error.location.line):\(error.location.column)")
            stackError = error.innerError as? HandleableError
        }
        if !stack.isEmpty {
            errorData[Constants.errorStackKey] = stack
        }
        
        switch error.state {
        case .acknowledged(at: let location, message: let message):
            errorData[Constants.errorStateKey] = "acknowledged"
            errorData[Constants.handlerMessageKey] = message
            errorData[Constants.handlerLocationKey] = "\(location.module)/\(location.file):\(location.line)"
        case .handled(at: let location, message: let message):
            errorData[Constants.errorStateKey] = "handled"
            errorData[Constants.handlerMessageKey] = message
            errorData[Constants.handlerLocationKey] = "\(location.module)/\(location.file):\(location.line)"
        case .ignored(at: let location, message: let message):
            errorData[Constants.errorStateKey] = "ignored"
            errorData[Constants.handlerMessageKey] = message
            errorData[Constants.handlerLocationKey] = "\(location.module)/\(location.file):\(location.line)"
            return logDebug("\(error.rootError)", in: .errorHandler, data: errorData)
        case .unhandled:
            errorData[Constants.errorStateKey] = "unhandled"
        }
        // Don't log ignorable errors unless they are marked as "debug"
        if error.isIgnorable && error.severity.logLevel != .debug { return }
        LogEvent(level: error.severity.logLevel,
                 message: error.message ?? "\(error.rootError)",
                 domain: error.location.domain,
                 data: errorData).log()
    }
}

extension ErrorHandler {
    enum Constants {
        static var errorTypeKey = "error.type"
        static var errorMessageKey = "error.message"
        static var errorLocationkey = "error.location"
        static var errorSeveritykey = "error.severity"
        static var errorStateKey = "error.state"
        static var errorStackKey = "error.stack"
        static var handlerMessageKey = "error.handler.message"
        static var handlerLocationKey = "error.handler.location"
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
        case .critical, .disruptive:
            return .error
        case .concerning:
            return .warning
        case .trivial:
            return .debug
        }
    }
}
