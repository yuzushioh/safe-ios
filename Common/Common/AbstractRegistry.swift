//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

open class AbstractRegistry {

    private static var instance = AbstractRegistry()
    private var services = [String: Any]()

    public class func put<T>(service: T, for type: T.Type) {
        instance.put(service: service, for: type)
    }

    public class func service<T>(for type: T.Type) -> T {
        return instance.service(for: type)
    }

}

// MARK: - Instance Methods

private extension AbstractRegistry {

    func put<T>(service: T, for type: T.Type) {
        services[key(type)] = service
    }

    func service<T>(for type: T.Type) -> T {
        return services[key(type)]! as! T
    }

    func key(_ type: Any.Type) -> String {
        return String(describing: type)
    }

}
