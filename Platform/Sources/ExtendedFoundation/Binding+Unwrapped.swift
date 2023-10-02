import SwiftUI

public extension Binding {
    
    /// Bootstraps a ``Binding`` of an ``Optional`` type to coalesce with a default value.
    /// The underlying ``Binding`` will be set to `nil` if the value that was set equals the default value.
    ///
    /// Usage
    ///
    /// ```swift
    /// TextField("Email", text: $member.email.unwrapped(or: ""))
    /// ```
    ///
    /// - Parameter defaultValue: The default value that will be used instead of nil.
    /// - Returns: A SwiftUI mutable ``Binding`` for use in form fields, etc.
    func unwrapped<T>(or defaultValue: T) -> Binding<T> where Value == Optional<T>, T: Equatable {
        Binding<T> {
            wrappedValue ?? defaultValue
        } set: { newValue in
            wrappedValue = newValue == defaultValue ? nil : newValue
        }
    }
}
