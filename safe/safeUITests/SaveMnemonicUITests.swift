//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
import CommonTestSupport

final class SaveMnemonicUITests: UITestCase {

    let saveMnemonicScreen = SaveMnemonicScreen()

    override func setUp() {
        super.setUp()
        givenSaveMnemonicSetup()
    }

    func test_contents() {
        XCTAssertTrue(saveMnemonicScreen.isDisplayed)
        XCTAssertEqual(saveMnemonicScreen.description.label, XCLocalizedString("new_safe.paper_wallet.description"))
        XCTAssertExist(saveMnemonicScreen.mnemonic)
        XCTAssertExist(saveMnemonicScreen.saveButton)
        XCTAssertExist(saveMnemonicScreen.continueButton)
    }

}
