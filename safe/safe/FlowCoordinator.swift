//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class FlowCoordinator {

    var rootVC: UINavigationController!

    func startViewController(parent: UINavigationController? = nil) -> UIViewController {
        rootVC = parent == nil ? TransparentNavigationController() : parent
        let startVC = flowStartController()
        if parent == nil {
            rootVC.setViewControllers([startVC], animated: false)
            return rootVC
        }
        return startVC
    }

    func flowStartController() -> UIViewController {
        assertionFailure("flowStartController should be overriden")
        return UIViewController()
    }

}

final class TransparentNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavBarTransparent()
    }

    func makeNavBarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }

}
