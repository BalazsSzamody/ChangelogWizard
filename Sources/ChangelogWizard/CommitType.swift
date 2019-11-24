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
    
    var tag: String {
        switch self {
        case .feature:
            return "[Feature]"
        case .bug:
            return "[FIX]"
        }
    }
    
    var title: String {
        switch self {
        case .feature:
            return "## New Features"
        case .bug:
            return "## Improvements"
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
    
    static func isUsingTags(_ commit: String) -> Bool {
        return allCases
            .map({ commit.contains($0.tag) })
            .reduce(false, { $0 || $1 })
    }
}

extension String {
    func commitsSinceLast(from commits: [String]) -> [String] {
        guard let index = commits.firstIndex(where: { $0.lowercased().contains(self.lowercased()) }) else {
            return commits
        }
        return Array(commits.prefix(upTo: index))
    }
}

extension Array where Element == String {
    func taggedCommits(_ commitType: CommitType) -> Self {
        return commitType.taggedCommits(from: self)
    }
    
    func commitsSinceLast(_ commitTag: String) -> Self {
        return commitTag.commitsSinceLast(from: self)
    }
}
