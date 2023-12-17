import Combine
import Foundation

/// A protocol that defines the API for interacting with the prayers data.
public protocol PrayersService {
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
}

/// A protocol that defines the API for interacting with the prayers data.
public protocol PrayersServiceDependency {
    associatedtype SomePrayersService: PrayersService
    /// A protocol that defines the API for interacting with the prayers data.
    var prayersService: PrayersService { get }
}
