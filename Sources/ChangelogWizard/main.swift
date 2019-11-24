#!/usr/bin/swift

import Foundation
import _ChangelogWizard

class Main {
    let changelogWizard: ChangelogWizard
    
    var args: [Argument] {
        return changelogWizard.args
    }
    
    init() throws {
        changelogWizard = try ChangelogWizard(CommandLine.arguments)
    }
    
    func test() throws {
        try changelogWizard.test()
    }
    
    func run() throws {
        try changelogWizard.run()
    }
}

//MARK: ------------   MAIN   ---------------
do {
    let main = try Main()
    guard !main.args.contains(where: { $0.isTest }) else {
        try main.test()
        exit(0)
    }
    try main.run()
    exit(0)
} catch {
    print(error.fullDescription())
    exit(1)
}
