//
//  ChangelogWizardTests.swift
//  
//
//  Created by Balazs Szamody on 21/11/19.
//

import Foundation
import XCTest
@testable import _ChangelogWizard

class ChangelogWizardTests: XCTestCase {
    
    var sut: ChangelogWizard!
    let gitService = MockGitService()
    
    func testMe() {
    }
    
    static var allTests = [
        ("testMe", testMe)
    ]
}
