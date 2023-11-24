import Combine
import Foundation

/// A protocol that defines the API for interacting with the members data.
public protocol MembersService {
    associatedtype SomeMember: Member
    
    /// Imports members from member data.
    /// - Parameter memberData: The member data to import.
    /// - Returns: A `SingleValueDataOperation` that emits a success message.
    func membersImport(fromMemberData memberData: String) -> SingleValueDataOperation<String>
    
    /// Creates a new member for a unit.
    /// - Parameters:
    ///   - member: The member to create.
    ///   - unitID: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits the created member data.
    func createMember(_ member: SomeMember, forUnitWithID unitID: String) -> SingleValueDataOperation<SomeMember>
    
    /// Retrieves the members in a unit.
    /// - Parameter unitID: The ID of the unit.
    /// - Returns: A `StreamDataOperation` that emits an array of members and continues to observe for future changes.
    func getUnitMembers(unitID: String) -> StreamDataOperation<[SomeMember]>
}
