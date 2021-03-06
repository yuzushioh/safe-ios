//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import safeUIKit

final class TextInputViewController: UIViewController {

    @IBOutlet weak var textInput: TextInput!

    @IBAction func addSuccessRule(_ sender: Any) {
        textInput.addRule("Success Rule") { _ in true }
    }

    @IBAction func addFailingRule(_ sender: Any) {
        textInput.addRule("Failing Rule") { _ in false }
    }

    @IBAction func addEmptyRule(_ sender: Any) {
        textInput.addRule("Empty Rule")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.accessibilityIdentifier = "testTextInput"
    }

}
