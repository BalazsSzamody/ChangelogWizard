//
//  Mocks.swift
//  
//
//  Created by Balazs Szamody on 24/11/19.
//

import Foundation
@testable import _ChangelogWizard

struct Mocks {
    static var args: [String] {
        return "--test --all --block-tag AUTO --branch origin/master --save test --tags first second third --titles First_section Second_Section Third_section".components(separatedBy: " ")
    }
    
    static var commitDump: String {
        return """
        f70f6a2 - BalazsSzamody, 10 hours ago : [FIX] 82 - Reduce App Binary Size by replacing oversized image assets (#20)
        771f978 - Jenkins 2, 12 hours ago : [AUTO] Version increased to 1.1.8(10)
        189bf2e - Unknown, 14 hours ago : Merge branch 'develop' into staging
        1fe9e8a - Unknown, 14 hours ago : [FIX] Updated pipeline.yml
        85dac7d - BalazsSzamody, 30 hours ago : [Feature] Changelog Tracking added to Fastlane (#19)
        7ccf2c9 - Jenkins 2, 35 hours ago : [AUTO] Version increased to 1.1.8(9)
        2175398 - Balazs Szamody, 2 days ago : Merge branch 'develop' into staging
        cda4f39 - Balazs Szamody, 2 days ago : [INTERNAL] Pipeline updated
        138dadb - Unknown, 2 days ago : Merge branch 'develop' into staging
        267c622 - Unknown, 2 days ago : Fixed the pipeline.yml for Nightly build
        cade60b - Jenkins 2, 3 days ago : [AUTO] Version increased to 1.1.8(7)
        792eb53 - Balazs Szamody, 3 days ago : Merge branch 'develop' into staging
        e144456 - Balazs Szamody, 3 days ago : Fastfile updated
        790b772 - Balazs Szamody, 3 days ago : Merge branch 'develop' into staging
        feeb073 - Balazs Szamody, 3 days ago : [Feature] Git_merge script added to control nightly build
        8ffb7f5 - Jenkins 2, 4 days ago : Version increased to 1.1.8(6)
        6be0bd3 - Balazs Szamody, 4 days ago : Merge branch 'develop' into staging
        cc9cb3d - Jenkins 2, 4 days ago : Version increased to 1.1.8(5)
        33be270 - Balazs Szamody, 6 days ago : pipeline tweak
        f8b89d5 - Balazs Szamody, 6 days ago : Merge branch 'develop' into staging
        1d92e01 - Balazs Szamody, 6 days ago : Pipeline yml fix
        d4bbc77 - Balazs Szamody, 6 days ago : Merge branch 'develop' into staging
        a55b124 - Balazs Szamody, 6 days ago : Merge branch 'fastlane' into develop
        5d7cf08 - Balazs Szamody, 6 days ago : Separated the build and upload step
        80e77da - Jenkins 2, 7 days ago : Version Increased
        17d8b1e - Balazs Szamody, 7 days ago : Merge branch 'develop' into staging
        4663fb4 - Balazs Szamody, 7 days ago : Bumped build number
        5c6677f - Balazs Szamody, 7 days ago : Merge branch 'develop' into staging
        1c3adb4 - Balazs Szamody, 7 days ago : Staging is recopied from Release
        9131b93 - Balazs Szamody, 7 days ago : Merge branch 'develop' into staging
        6637592 - Balazs Szamody, 7 days ago : Merge branch 'fastlane_tweak' into develop
        """
    }
}


struct MockGitService: GitService {
    func getLastTag() throws -> String {
        return "1.1.1"
    }

    func getCommits(branch: String?, range: String?) throws -> String {
        let commits = Mocks.commitDump
        if range != nil {
            return commits
                .components(separatedBy: "\n")
                .prefix(6)
                .joined(separator: "\n")
        }

        return commits
    }
}
