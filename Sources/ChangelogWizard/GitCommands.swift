//
//  GitCommands.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

enum GitCommands {
    case getLastTag
    case getCommits(range: String?)
    
    var command: String {
        switch self {
        case .getLastTag:
            return "git describe --tags --abbrev=0"
        case .getCommits(let range):
            return "git log origin/develop --pretty=format:\"%h - %an, %ar : %s\"" + (range != nil ? " \(range!)" : "")
        }
    }
    
    func output() throws -> String {
        return try Process.shell([command])
    }
}
