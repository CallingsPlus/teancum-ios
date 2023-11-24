import Combine
import Foundation

/// A protocol that defines the API for interacting with the units data.
public protocol UnitsService {
    associatedtype SomeUnit: Unit
    associatedtype SomeUser: User
    
    /// Creates a new unit with the specified name.
    /// - Parameter name: The name of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits the ID of the created unit.
    func createUnit(name: String) -> SingleValueDataOperation<String>
    
    /// Retrieves a unit by its ID.
    /// - Parameter id: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits the unit data.
    func getUnit(id: String) -> SingleValueDataOperation<SomeUnit>
    
    /// Retrieves the invite token for a unit.
    /// - Returns: A `SingleValueDataOperation` that emits the invite token.
    func getUnitInviteToken() -> SingleValueDataOperation<String>
    
    /// Retrieves the users in a unit.
    /// - Parameter unitID: The ID of the unit.
    /// - Returns: A `StreamDataOperation` that emits an array of users and continues to observe for future changes.
    func getUnitUsers(unitID: String) -> StreamDataOperation<[SomeUser]>
    
    /// Joins a unit using an invite token.
    /// - Parameter inviteToken: The invite token for the unit.
    /// - Returns: A `SingleValueDataOperation` that emits the ID of the joined unit.
    func joinUnit(withInviteToken inviteToken: String) -> SingleValueDataOperation<String>
}
