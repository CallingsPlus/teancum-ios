import Combine
import Foundation

/// A protocol that defines the API for interacting with the app's data store.
public protocol CallingsPlusAPIDependency {
    associatedtype SomeAppAPI: CallingsPlusAPI
    var api: SomeAppAPI { get }
}

/// A protocol that defines the API for interacting with the app's data store.
public protocol CallingsPlusAPI {
    associatedtype SomeUser: User
    associatedtype SomeUnit: Unit
    associatedtype SomeMember: Member
    
    // MARK: - User
    
    /// Retrieves a user by their ID.
    /// - Parameter userID: The ID of the user.
    /// - Returns: A `StreamDataOperation` that emits the user data and continues to observe for future changes.
    func getUser(byID userID: String) -> StreamDataOperation<SomeUser>
    
    // MARK: - Units
    
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
    
    // MARK: - Members
    
    /// Imports members from member data.
    /// - Parameter memberData: The member data to import.
    /// - Returns: A `SingleValueDataOperation` that emits a success message.
    func membersImport(fromMemberData memberData: String) -> SingleValueDataOperation<String>
    
    /// Creates a new member for a unit.
    /// - Parameters:
    ///   - member: The member to create.
    ///   - unitID: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits the created member data.
    func memberCreate(fromMember member: SomeMember, forUnitWithID unitID: String) -> SingleValueDataOperation<SomeMember>
    
    /// Retrieves the members in a unit.
    /// - Parameter unitID: The ID of the unit.
    /// - Returns: A `StreamDataOperation` that emits an array of members and continues to observe for future changes.
    func getUnitMembers(unitID: String) -> StreamDataOperation<[SomeMember]>
    
    // MARK: - Prayers
    
    /// Records a prayer for a member in a unit on a specific date.
    /// - Parameters:
    ///   - date: The date of the prayer.
    ///   - memberID: The ID of the member.
    ///   - unitID: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits a success message.
    func recordPrayer(onDate date: Date, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void>
    
    /// Updates the prayer statistic for a member in a unit.
    /// - Parameters:
    ///   - prayerStatistic: The prayer statistic to update.
    ///   - change: The type of change to apply to the statistic.
    ///   - memberID: The ID of the member.
    ///   - unitID: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits a success message.
    func update(prayerStatistic: PrayerStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void>
    
    // MARK: - Talks
    
    /// Records a talk for a member in a unit on a specific date.
    /// - Parameters:
    ///   - date: The date of the talk.
    ///   - topic: The topic of the talk.
    ///   - memberID: The ID of the member.
    ///   - unitID: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits a success message.
    func recordTalk(onDate date: Date, topic: String?, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void>
    
    /// Updates the talk statistic for a member in a unit.
    /// - Parameters:
    ///   - talkStatistic: The talk statistic to update.
    ///   - change: The type of change to apply to the statistic.
    ///   - memberID: The ID of the member.
    ///   - unitID: The ID of the unit.
    /// - Returns: A `SingleValueDataOperation` that emits a success message.
    func update(talkStatistic: TalkStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void>
}
