import Combine
import Foundation

/// A protocol that defines the API for interacting with the talks data.
public protocol TalksService {
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