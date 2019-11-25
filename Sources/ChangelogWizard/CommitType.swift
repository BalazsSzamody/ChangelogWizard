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
}

typealias CommitMessage = String
typealias CommitTag = String

extension CommitMessage {
    func isUsingTags(_ tags: [CommitTag]) -> Bool {
        return tags
            .map({ self.lowercased().contains($0.lowercased()) })
        .reduce(false, { $0 || $1 })
    }
}

extension Array where Element == CommitMessage {
    func taggedCommits(_ commitType: CommitType) -> Self {
        return taggedCommits(commitType.tag)
    }
    
    func taggedCommits(_ tag: CommitTag) -> Self {
        let tag = tag.lowercased()
        return self
            .filter({ $0.lowercased().contains(tag) })
        .map({ commit -> String in
            return "- " + commit
                .components(separatedBy: " ")
                .filter({ $0 != tag })
                .joined(separator: " ")
        })
        .reversed()
    }
    
    func commitsSinceLast(_ commitTag: CommitTag) -> Self {
        guard let index = self.firstIndex(where: { $0.lowercased().contains(commitTag.lowercased()) }) else {
            return self
        }
        return Array(self.prefix(upTo: index))
    }
}
