//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import IdentityAccessDomainModel

public class ApplicationServiceRegistry: AbstractRegistry {

    public static var authenticationService: AuthenticationApplicationService {
        return service(for: AuthenticationApplicationService.self)
    }

    public static var identityService: IdentityApplicationService {
        return service(for: IdentityApplicationService.self)
    }

    public static var clock: Clock {
        return service(for: Clock.self)
    }

    public static var logger: Logger {
        return service(for: Logger.self)
    }

}
