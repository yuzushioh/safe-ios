//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel
import Common

open class AuthenticationApplicationService {

    public enum Error: Swift.Error, Hashable {
        case emptyPassword
    }

    private var gatekeeperRepository: SingleGatekeeperRepository { return DomainRegistry.gatekeeperRepository }
    private var clock: Clock { return ApplicationServiceRegistry.clock }
    private var identityService: IdentityService { return DomainRegistry.identityService }
    private var userRepository: SingleUserRepository { return DomainRegistry.userRepository }
    private var biometricService: BiometricAuthenticationService {
        return DomainRegistry.biometricAuthenticationService
    }
    private var isAccessPossible: Bool {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return false }
        return gatekeeper.isAccessPossible(at: clock.currentTime)
    }

    public init() {}

    // MARK: - Queries

    open var blockedPeriodDuration: TimeInterval {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return 15 }
        return gatekeeper.policy.blockDuration
    }
    open var maxPasswordAttempts: Int {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return 5 }
        return gatekeeper.policy.maxFailedAttempts
    }
    open var sessionDuration: TimeInterval {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return 60 }
        return gatekeeper.policy.sessionDuration
    }
    open var isUserAuthenticated: Bool {
       return identityService.isUserAuthenticated(at: clock.currentTime)
    }
    open var isUserRegistered: Bool {
        return userRepository.primaryUser() != nil
    }
    open var isAuthenticationBlocked: Bool {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return false }
        return !gatekeeper.isAccessPossible(at: clock.currentTime)
    }

    open func isAuthenticationMethodSupported(_ method: AuthenticationMethod) -> Bool {
        var supportedSet: AuthenticationMethod = .password
        if biometricService.biometryType == .touchID {
            supportedSet.insert(.touchID)
        }
        if biometricService.biometryType == .faceID {
            supportedSet.insert(.faceID)
        }
        return supportedSet.intersects(with: method)
    }

    open func isAuthenticationMethodPossible(_ method: AuthenticationMethod) -> Bool {
        guard isAccessPossible else { return false }
        var possibleSet: AuthenticationMethod = .password
        if isAuthenticationMethodSupported(.faceID) && biometricService.isAuthenticationAvailable {
            possibleSet.insert(.faceID)
        }
        if isAuthenticationMethodSupported(.touchID) && biometricService.isAuthenticationAvailable {
            possibleSet.insert(.touchID)
        }
        return possibleSet.intersects(with: method)
    }

    // MARK: - Commands

    open func authenticateUser(_ request: AuthenticationRequest) throws -> AuthenticationResult {
        let time = clock.currentTime
        let user: UserID?
        if request.method == .password {
            user = try identityService.authenticateUser(password: request.password, at: time)
        } else if AuthenticationMethod.biometry.contains(request.method) {
            user = try identityService.authenticateUserBiometrically(at: time)
        } else {
            preconditionFailure("Invalid authentication method in request \(request)")
        }
        if let user = user {
            return .success(userID: user.id)
        } else if isAccessPossible {
            return .failure
        } else {
            return .blocked
        }
    }

    open func registerUser(password: String) throws {
        _ = try DomainRegistry.identityService.registerUser(password: password)
    }

    open func configureSession(_ duration: TimeInterval) throws {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return }
        try gatekeeper.changeSessionDuration(duration)
        try gatekeeperRepository.save(gatekeeper)
    }

    open func configureMaxPasswordAttempts(_ count: Int) throws {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return }
        try gatekeeper.changeMaxFailedAttempts(count)
        try gatekeeperRepository.save(gatekeeper)
    }

    open func configureBlockDuration(_ duration: TimeInterval) throws {
        guard let gatekeeper = gatekeeperRepository.gatekeeper() else { return }
        try gatekeeper.changeBlockDuration(duration)
        try gatekeeperRepository.save(gatekeeper)
    }

    open func createAuthenticationPolicy(sessionDuration: TimeInterval,
                                         maxPasswordAttempts: Int,
                                         blockedPeriodDuration: TimeInterval) throws {
        try identityService.createGatekeeper(sessionDuration: sessionDuration,
                                             maxFailedAttempts: maxPasswordAttempts,
                                             blockDuration: blockedPeriodDuration)
    }

    open func reset() throws {
        if let user = userRepository.primaryUser() {
            try userRepository.remove(user)
        }
        if let gatekeeper = gatekeeperRepository.gatekeeper() {
            gatekeeper.reset()
            try DomainRegistry.gatekeeperRepository.save(gatekeeper)
        }
    }

}
