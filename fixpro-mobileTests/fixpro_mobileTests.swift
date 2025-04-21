import Foundation
import Testing
import VinUtility
@testable import fixpro_mobile

struct fixpro_mobileTests {
    
    struct MockStorage: VUPlacerQuerist & VURemoverQuerist & VURetrieverQuerist {
        
        func place(for key: String, data: String) -> Result<Bool, FPError> {
            .success(true)
        }
        
        func remove(for key: String) -> Result<Bool, FPError> {
            .success(true)
        }
        
        func check(for key: String) -> Result<Bool, FPError> {
            .success(true)
        }
        
        func retrieve(for key: String, limit: Int) -> Result<String, FPError> {
            .success("")
        }
        
    }
    
    
    struct MockSnapshotableTarget: VUMementoPerfectSnapshotable {
        func captureSnapshot() async -> Result<MockSnapshotableTargetSnapshot, Never> {
            .success(.init(id: UUID(), takenOn: .now))
        }
        
        func restore(toSnapshot snapshot: MockSnapshotableTargetSnapshot) async -> Result<Void, Never> {
            .success(())
        }
        
        static func boot(fromSnapshot snapshot: MockSnapshotableTargetSnapshot) -> Result<MockSnapshotableTarget, Never> {
            .success(.init())
        }
    }
    
    struct MockSnapshotableTargetSnapshot: VUMementoSnapshot {
        var id: UUID
        var tag: String?
        var takenOn: Date
        var version: String?
        
        var stupid: String?
    }
    
    struct MockSnapshotableTarget3Snapshot: VUMementoSnapshot {
        var id: UUID
        var tag: String?
        var takenOn: Date
        var version: String?
        
        var something: String?
    }

    @Test func example() async throws {
        let mockStorage = MockStorage()
        let mockSnapshotableTarget = MockSnapshotableTarget()
        let mementoAgent = FPMementoAgent<MockSnapshotableTarget, MockSnapshotableTargetSnapshot>(storage: mockStorage, target: mockSnapshotableTarget, storageKey: "")
        
        VULogger.log(try await mementoAgent.snap().get())
        
        VULogger.log(try await mementoAgent.cold(restore: MockSnapshotableTarget.self).get())
    }

}
