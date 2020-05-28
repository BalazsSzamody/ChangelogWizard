//
//  GitCommands.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

enum GitCommands {
    case getLastTag
    case getCommits(date: String?)
    case getCommitDetails(commit: String?, format: String)
    case getLastMergeDate(date: String)
    
    var command: String {
        switch self {
        case .getLastTag:
            return "git describe --tags --abbrev=0"
        case .getCommits(let date):
            return "git log --pretty=oneline" + (date != nil ? " --after=\(date!)" : "")
        case .getCommitDetails(let commit, let format):
            return ["git show --pretty=\(format)", commit]
            .compactMap({ $0 })
            .joined(separator: " ")
        case .getLastMergeDate(let date):
            return """
                    git log --after="\(date)" --pretty=oneline
                    """
        }
    }
    
    func output() throws -> String {
        return try Process.shell([command])
    }
}
