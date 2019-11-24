//
//  GitCommands.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

protocol GitService {
    func getLastTag() throws -> String
    func getCommits(branch: String?, range: String?) throws -> String
}

struct GitServiceImp: GitService {
    public init() {}
    
    func getLastTag() throws -> String {
        try GitCommands.getLastTag()
    }
    
    func getCommits(branch: String?, range: String?) throws -> String {
        try GitCommands.getCommits(branch: branch, range: range)
    }
}

enum GitCommands {
    case lastTag
    case commits(branch: String?, range: String?)
    
    var command: String {
        switch self {
        case .lastTag:
            return "git describe --tags --abbrev=0"
        case .commits(let branch, let range):
            return "git log \(branch != nil ? branch! : "") --pretty=format:\"%h - %an, %ar : %s\"" + (range != nil ? " \(range!)" : "")
        }
    }
    
    func output() throws -> String {
        return try Process.shell([command])
    }
    
    static func getLastTag() throws -> String {
        return try Self.lastTag.output()
    }
    
    static func getCommits(branch: String?, range: String?) throws -> String {
        return try Self.commits(branch: branch, range: range).output()
    }
}
