//
//  ArrayExtension.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

extension Array where Element == String {
    func taggedCommits(_ commitType: CommitType) -> Self {
        return commitType.taggedCommits(from: self)
    }
    
    func commitsSinceLast(_ commitType: CommitType) -> Self {
        return commitType.commitsSinceLast(from: self)
    }
}
