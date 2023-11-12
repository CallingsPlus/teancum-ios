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
    func unwrapped<OutputValue>(or defaultValue: OutputValue) -> Binding<OutputValue> where Value == Optional<OutputValue>, OutputValue: Equatable {
        Binding<OutputValue> {
            wrappedValue ?? defaultValue
        } set: { newValue in
            wrappedValue = newValue == defaultValue ? nil : newValue
        }
    }
}
