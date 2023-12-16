import DataServices
import Foundation

#if DEBUG

/// A local-memory API that mimics a real API for testing various components of the app
public class StubAPI: MembersService, PrayersService, TalksService, UnitsService, UserService {
    /// Simulates network delay
    public var simulatedDelayInMilliseconds: Int?
    public var unit: MockUnit = .init()
    public var user: MockUser = .init()
    public var unitMembers: [MockMember] = []
    public var unitUsers: [MockUser] = []
    
    public init() { }
    
    // MARK: - User
    
    public func getUser(byID userID: String) -> StreamDataOperation<MockUser> {
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
    
    public func getUnit(id: String) -> SingleValueDataOperation<MockUnit> {
        .async {
            try await self.simulateDelayIfNecessary {
                self.unit
            }
        }
    }
    
    public func getUnitUsers(unitID: String) -> StreamDataOperation<[MockUser]> {
        .stream {
            .init(unfolding: {
                try await self.simulateDelayIfNecessary {
                    self.unitUsers
                }
            })
        }
    }
    
    // MARK: - Members
        
    
    public func createMember(_ member: MockMember, forUnitWithID unitID: String) -> SingleValueDataOperation<MockMember> {
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
    
    public func getUnitMembers(unitID: String) -> StreamDataOperation<[MockMember]> {
        .stream {
            .init(unfolding: {
                try await self.simulateDelayIfNecessary {
                    self.unitMembers
                }
            })
        }
    }
    
    public func initializeMember() -> MockMember {
        MockMember(id: UUID().uuidString, firstName: "", lastName: "", isHidden: false, hasGivenPermission: false)
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

extension StubAPI {
    func simulateDelayIfNecessary<Result>(completion: () -> Result) async throws -> Result {
        if let simulatedDelayInMilliseconds = self.simulatedDelayInMilliseconds {
            try await Task.sleep(for: .milliseconds(simulatedDelayInMilliseconds))
        }
        return completion()
    }
}

#endif
