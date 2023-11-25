import DataServices
import Foundation

/// A local-memory API that mimics a real API for testing various components of the app
public class LocalAPI: MembersService, PrayersService, TalksService, UnitsService, UserService {
    /// Simulates network delay
    public var simulatedDelayInMilliseconds: Int?
    public var unit: LocalUnit = .init()
    public var user: LocalUser = .init()
    public var unitMembers: [LocalMember] = []
    public var unitUsers: [LocalUser] = []
    
    // MARK: - User
    
    public func getUser(byID userID: String) -> StreamDataOperation<LocalUser> {
        .stream {
            .init(unfolding: {
                try await self.simulateDelayIfNecessary {
                    self.user
                }
            })
        }
    }
    
    // MARK: - Units
    
    public func createUnit(name: String) -> SingleValueDataOperation<String> {
        .async {
            try await self.simulateDelayIfNecessary {
                ""
            }
        }
    }
    
    public func joinUnit(withInviteToken inviteToken: String) -> SingleValueDataOperation<String> {
        .async {
            try await self.simulateDelayIfNecessary {
                ""
            }
        }
    }
    
    public func getUnitInviteToken() -> SingleValueDataOperation<String> {
        .async {
            try await self.simulateDelayIfNecessary {
                "some_invite_token"
            }
        }
    }
    
    public func getUnit(id: String) -> SingleValueDataOperation<LocalUnit> {
        .async {
            try await self.simulateDelayIfNecessary {
                self.unit
            }
        }
    }
    
    public func getUnitUsers(unitID: String) -> StreamDataOperation<[LocalUser]> {
        .stream {
            .init(unfolding: {
                try await self.simulateDelayIfNecessary {
                    self.unitUsers
                }
            })
        }
    }
    
    // MARK: - Members
        
    
    public func createMember(_ member: LocalMember, forUnitWithID unitID: String) -> SingleValueDataOperation<LocalMember> {
        .async {
            try await self.simulateDelayIfNecessary {
                member
            }
        }
    }
    
    public func membersImport(fromMemberData memberData: String) -> SingleValueDataOperation<String> {
        .async {
            "result"
        }
    }
    
    public func getUnitMembers(unitID: String) -> StreamDataOperation<[LocalMember]> {
        .stream {
            .init(unfolding: {
                try await self.simulateDelayIfNecessary {
                    self.unitMembers
                }
            })
        }
    }
    
    // MARK: - Prayers
        
    public func recordPrayer(onDate date: Date, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            try await self.simulateDelayIfNecessary {
                Void()
            }
        }
    }
    
    public func update(prayerStatistic: PrayerStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            try await self.simulateDelayIfNecessary {
                Void()
            }
        }
    }
    
    // MARK: - Talks
    
    
    public func recordTalk(onDate date: Date, topic: String?, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            try await self.simulateDelayIfNecessary {
                Void()
            }
        }
    }
    
    public func update(talkStatistic: TalkStatistic, change: ChangeType, forMemberWithID memberID: String, inUnitWithID unitID: String) -> SingleValueDataOperation<Void> {
        .async {
            try await self.simulateDelayIfNecessary {
                Void()
            }
        }
    }
}

extension LocalAPI {
    func simulateDelayIfNecessary<Result>(completion: () -> Result) async throws -> Result {
        if let simulatedDelayInMilliseconds = self.simulatedDelayInMilliseconds {
            try await Task.sleep(for: .milliseconds(simulatedDelayInMilliseconds))
        }
        return completion()
    }
}
