import Foundation

/// Determines the app's operating environment. Specifically, which data service endpoints and APIs are used when the app is launched. Configured by launch argument.
enum AppEnvironment {
    /// The app will interact with the production data services. This should be used for release builds or production manual integration testing only.
    /// This environment is used by default unless another environment is indicated by passing in the corresponding launch argument.
    case production
    
    /// The app will interact with the staging data services. This can be used for automated integration testing, but the data may not be reliable.
    /// To target this environment, pass the launch argument `-stage` or `-staging`
    case staging
    
    /// The app will interact with locally hosted data services. This can be used for integration testing data services that are still in development.
    /// To target this environment, pass the launch argument `-local` or `-localhost`
    case localhost
    
    /// The app will interact with in-memory data services that mimic a real data service.
    /// The values will not persist between launches and must be configured with seed data on each launch.
    /// This can be used for rapid client code development and prototyping
    /// To target this environment, pass the launch argument `-mock` or `-mocked`
    case mock
    
    /// The app will do nothing and display nothing for performant unit tests.
    /// This environment is automatically detected and cannot be overridden by compiler flag.
    case unitTesting
}

extension AppEnvironment {
    /// Gets the current app environment from the launch args
    static var current: AppEnvironment = {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-stage") || arguments.contains("-staging") {
            return .staging
        } else if arguments.contains("-local") || arguments.contains("-localhost") {
            return .localhost
        } else {
            return .production
        }
    }()
}
