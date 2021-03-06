//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class GatekeeperID: BaseID {}

public class Gatekeeper: IdentifiableEntity<GatekeeperID> {

    public enum Error: Swift.Error, Hashable {
        case durationIsNotPositive
        case accessBlocked
    }

    private struct State: Codable {
        fileprivate let id: String
        fileprivate let session: Data?
        fileprivate let policy: AuthenticationPolicy
        fileprivate let failedAttemptCount: Int
        fileprivate let accessDeniedAt: Date?
    }

    public private(set) var policy: AuthenticationPolicy {
        didSet {
            reset()
        }
    }
    private var session: Session?
    private var failedAttemptCount: Int = 0
    private var accessDeniedAt: Date?

    public init(id: GatekeeperID, policy: AuthenticationPolicy) throws {
        self.policy = policy
        super.init(id: id)
    }

    public convenience init(data: Data) throws {
        let decoder = PropertyListDecoder()
        let state = try decoder.decode(State.self, from: data)
        try self.init(id: try GatekeeperID(state.id), policy: state.policy)
        if let data = state.session {
            session = try Session(data: data)
        }
        failedAttemptCount = state.failedAttemptCount
        accessDeniedAt = state.accessDeniedAt
    }

    public func data() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = State(id: id.id,
                          session: try session?.data(),
                          policy: policy,
                          failedAttemptCount: failedAttemptCount,
                          accessDeniedAt: accessDeniedAt)
        return try encoder.encode(state)
    }

    public func changeSessionDuration(_ newValue: TimeInterval) throws {
        policy = try policy.withSessionDuration(newValue)
    }

    public func changeMaxFailedAttempts(_ newValue: Int) throws {
        policy = try policy.withMaxFailedAttempts(newValue)
    }

    public func changeBlockDuration(_ newValue: TimeInterval) throws {
        policy = try policy.withBlockDuration(newValue)
    }

    public func isAccessPossible(at time: Date) -> Bool {
        guard let deniedTime = accessDeniedAt else { return true }
        let blockLiftTime = deniedTime.addingTimeInterval(policy.blockDuration)
        let isBlockPeriodExpired = time >= blockLiftTime
        let hasMoreAttempts = failedAttemptCount < policy.maxFailedAttempts
        return hasMoreAttempts || isBlockPeriodExpired
    }

    public func allowAccess(at time: Date) throws -> SessionID {
        try assertNotBlocked(at: time)
        let session = try Session(id: SessionID(UUID().uuidString), durationInSeconds: policy.sessionDuration)
        try session.start(time)
        self.session = session
        failedAttemptCount = 0
        accessDeniedAt = nil
        return session.id
    }

    private func assertNotBlocked(at time: Date) throws {
        try assertTrue(isAccessPossible(at: time), Error.accessBlocked)
    }

    public func denyAccess(at time: Date) {
        session = nil
        failedAttemptCount += 1
        accessDeniedAt = time
    }

    public func hasAccess(session id: SessionID, at time: Date) -> Bool {
        guard let session = session, session.id == id else { return false }
        return session.isActiveAt(time)
    }

    public func useAccess(at time: Date) throws {
        try assertNotBlocked(at: time)
        try session?.renew(time)
    }

    public func reset() {
        session = nil
        failedAttemptCount = 0
        accessDeniedAt = nil
    }

}
