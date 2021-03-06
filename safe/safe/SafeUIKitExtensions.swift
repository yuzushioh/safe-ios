//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

extension UIApplication {

    static var rootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

}
