import Foundation

public extension Optional {
    
    /// Returns the underlying value or the default value if `nil`.
    /// - Parameter defaultValue: The default value to use when the underlying value is nil when accessed.
    /// - Returns: The unwrapped value or the default value.
    func or(_ defaultValue: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return defaultValue
        case .some(let wrapped):
            return wrapped
        }
    }
    
    /// Returns the underlying value or throws an error if `nil`
    var orThrow: Wrapped {
        get throws {
            try self.orThrow(UnwrapError(description: "nil found when unwrapping \(type(of: self))"))
        }
    }
        
    /// Returns the underlying value or throws an error if `nil`
    /// - Parameter error: The error to throw when the underlying value is nil when accessed.
    /// - Returns: The unwrapped value
    func orThrow(_ error: Error) throws -> Wrapped {
        switch self {
        case .none:
            throw error
        case .some(let wrapped):
            return wrapped
        }
    }
    
    /// Represent an attempt to unwrap a `nil` value
    struct UnwrapError: Error, CustomStringConvertible {
        public var description: String
    }
}
