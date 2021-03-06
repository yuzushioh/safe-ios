//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol KeyValueStore {
    func bool(for key: String) -> Bool?
    func setBool(_ value: Bool, for key: String)
    func int(for key: String) -> Int?
    func setInt(_ value: Int, for key: String)
    func deleteKey(_ key: String)
}
