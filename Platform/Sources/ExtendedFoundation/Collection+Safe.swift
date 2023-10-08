import Foundation

extension Collection {
    /// Returns the value at the specified index or nil if the index is out of range.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
