//
//  Arguments.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

enum Arguments: Equatable {
    case verbose
    case commit(String)
    case noVersion
    case test
    case all
    
    static var defaultFileName: String {
        return "changelog_staging.md"
    }
    
    static var current: [Arguments] = []
    
    static func parse(_ args: [String]) {
        current = args.compactMap({
            let arg = $0.dropFrontDash()
            switch arg {
            case "verbose":
                return .verbose
            case "commit":
                
                guard let index = args.firstIndex(of: $0),
                    args.count > index + 1 else {
                    print("Commit hash not found")
                    exit(1)
                }
                return .commit(args[index + 1])
            case "test":
                return .test
            case "no-version":
                return .noVersion
            case "all":
                return .all
            default:
                return nil
            }
        })
    }
}
