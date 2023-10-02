import Foundation

public extension String {
    /// Returns true if a string is empty or contains only white spaces (or newlines)
    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
