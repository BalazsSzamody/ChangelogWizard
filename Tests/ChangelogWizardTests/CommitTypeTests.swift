//
//  CommitTypeTests.swift
//  
//
//  Created by Balazs Szamody on 25/11/19.
//

import Foundation
import XCTest
@testable import _ChangelogWizard

class CommitTypeTests: XCTestCase {
    
    func testIsUsingTags() {
        let tags = ["[TEST]", "[AUTO]", "[Feature]", "[FIX]"]
        var message = "f70f6a2 - BalazsSzamody, 10 hours ago : [FIX] 82 - Reduce App Binary Size by replacing oversized image assets (#20)"
        
        XCTAssertTrue(message.isUsingTags(tags))
        
        message = message.replacingOccurrences(of: "FIX", with: "fix")
        XCTAssertTrue(message.isUsingTags(tags))
        
        message = message.replacingOccurrences(of: "fix", with: "auto")
        XCTAssertTrue(message.isUsingTags(tags))
        
        message = message.replacingOccurrences(of: "auto", with: "no")
        XCTAssertFalse(message.isUsingTags(tags))
    }
    
    func testTaggedCommits() {
        let fix = "[fix]"
        let feature = CommitType.feature
        let auto = "[AUTO]"
        let test = "[Test]"
        
        let commits = Mocks.commitDump
            .components(separatedBy: "\n")
        
        let fixes = commits.taggedCommits(fix)
        let features = commits.taggedCommits(feature)
        let autos = commits.taggedCommits(auto)
        let tests = commits.taggedCommits(test)
        
        XCTAssertEqual(fixes.count, 2)
        XCTAssertEqual(features.count, 2)
        XCTAssertEqual(autos.count, 3)
        XCTAssertEqual(tests.count, 0)
    }
    
    func testCommitSinceLastTag() {
        let internalTag = "[Internal]"
        let fix = CommitType.bug.tag
        
        let commits = Mocks
            .commitDump
            .components(separatedBy: "\n")
        
        let commitsSinceInternal = commits.commitsSinceLast(internalTag)
        let commitsSinceFix = commits.commitsSinceLast(fix)
        
        XCTAssertEqual(commitsSinceInternal.count, 7)
        XCTAssertEqual(commitsSinceFix.count, 0)
    }
}
