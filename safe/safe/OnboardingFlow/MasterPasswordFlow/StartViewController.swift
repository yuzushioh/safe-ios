//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

protocol StartViewControllerDelegate: class {
    func didStart()
}

final class StartViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    private weak var delegate: StartViewControllerDelegate?

    struct LocalizedString {
        static let header = NSLocalizedString("onboarding.start.header", "App name")
        static let description = NSLocalizedString("onboarding.start.description", "App slogan")
        static let start = NSLocalizedString("onboarding.start.start", "Start button title")
    }

    static func create(delegate: StartViewControllerDelegate) -> StartViewController {
        let vc = StoryboardScene.MasterPassword.startViewController.instantiate()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = LocalizedString.header
        descriptionLabel.text = LocalizedString.description
        startButton.setTitle(LocalizedString.start, for: .normal)
    }

    @IBAction func start(_ sender: Any) {
        delegate?.didStart()
    }

}