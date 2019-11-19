//
//  Arguments.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

enum Arguments: String {
    case tag = "--tag"
    
    var fileName: String {
        switch self {
        case .tag:
            return "changelog.md"
        }
    }
    
    static var defaultFileName: String {
        return "changelog_staging.md"
    }
}
