//
//  CommitType.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

enum CommitType: CaseIterable {
    case feature
    case bug
    case auto
    
    var tag: String {
        switch self {
        case .feature:
            return "[Feature]"
        case .bug:
            return "[FIX]"
        case .auto:
            return "[AUTO]"
        }
    }
    
    var title: String {
        switch self {
        case .feature:
            return "## New Features"
        case .bug:
            return "## Improvements"
        default:
            return ""
        }
    }
    
    func taggedCommits(from commits: [String]) -> [String] {
        let tag = self.tag
        return commits
            .filter({ $0.contains(tag) })
            .map({ commit -> String in
                return "- " + commit
                    .components(separatedBy: " ")
                    .filter({ $0 != tag })
                    .joined(separator: " ")
            })
            .reversed()
    }
    
    func commitsSinceLast(from commits: [String]) -> [String] {
        guard let index = commits
            .firstIndex(where: { $0.contains(self.tag) }) else {
                return commits
        }
        return Array(commits.prefix(upTo: index))
    }
    
    static func isUsingTags(_ commit: String) -> Bool {
        return allCases
            .map({ commit.contains($0.tag) })
            .reduce(false, { $0 || $1 })
    }
}
