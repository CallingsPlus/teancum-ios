import Foundation

public struct LocatableError: Error {
    public var innerError: Error
    public var location: Location
}

extension Error {
    /// Makes a locatable version of this error, containing the module, file, line, and column of the error.
    /// This will not override an already locatable error
    func locatable(fileID: String = #fileID, line: Int = #line, column: Int = #column) -> LocatableError {
        (self as? LocatableError) ?? LocatableError(innerError: self, location: .init(fileID: fileID, line: line, column: column))
    }
}
