import SwiftUI

public extension Binding {
    
    /// Maps the type of a Binding to another type while preserving the binding behavior.
    ///
    /// Usage
    ///
    /// ```swift
    /// ErrorView(isPresented: $error.mapped(
    ///     to: { error in
    ///         error != nil
    ///     },
    ///     from: { error, isPresented in
    ///         isPresented ? error : nil
    ///     }
    /// ))
    /// ```
    ///
    /// - Parameters:
    ///   - outputMap: Closure or function for converting the original binding value to the new type.
    ///   - inputMap: Closure or function for converting and setting the new value type assignment to the original binding. Includes the previous original value for optional processing.
    /// - Returns: A ``Binding`` that supersedes the old binding
    func mapped<OutputValue>(to outputMap: @escaping (Value) -> OutputValue, from inputMap: @escaping (Value, OutputValue) -> Value) -> Binding<OutputValue> {
        Binding<OutputValue> {
            outputMap(wrappedValue)
        } set: { newValue in
            wrappedValue = inputMap(wrappedValue, newValue)
        }
    }
}
