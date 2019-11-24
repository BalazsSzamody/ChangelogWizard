//
//  Arguments.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

public enum ArgumentError: Error {
    case missingParam(String)
    case missingTagsOrTitles(tags: Bool, titles: Bool)
    case tagTitleMismatch(tags: [String]?, titles: [String]?)
    
    public var localizedDescription: String {
        switch self {
        case .missingParam(let customPart):
            return "Argument needs a parameter. \(customPart)"
        case .missingTagsOrTitles(let hasTags, let hastitles):
            return "Please provide both or neither tags and titles. Tags \(hasTags ? "" : "not ")found, Titles \(hastitles ? "" : "not") found"
        case .tagTitleMismatch(let tags, let titles):
            return "Please provide equal number of tags and titles. For spaced titles use '_' instead of spaces.(tags: \(tags?.description ?? "nil"), titles: \(titles?.description ?? "nil")"
        }
    }
}

public enum Argument {
    case test
    case blockTag(name: String?)
    case branch(name: String)
    case save(fileName: String?)
    case tags([String])
    case titles([String])
    case all
    
    public var isTest: Bool {
        switch self {
        case .test:
            return true
        default:
            return false
        }
    }
    
    var isAll: Bool {
        switch self {
        case .all:
            return true
        default:
            return false
        }
    }
    
    var isBlockTag: Bool {
        switch self {
        case .blockTag:
            return true
        default:
            return false
        }
    }
    
    var isSave: Bool {
        switch self {
        case .save:
            return true
        default:
            return false
        }
    }
    
    var isBranch: Bool {
        switch self {
            case .branch:
                return true
            default:
                return false
        }
    }
    
    var isTags: Bool {
        switch self {
            case .tags:
                return true
            default:
                return false
        }
    }
    
    var isTitles: Bool {
        switch self {
            case .titles:
                return true
            default:
                return false
        }
    }
    
    var tags: [String] {
        switch self {
            case .tags(let tags):
                return tags
            default:
                return []
        }
    }
    
    var titles: [String] {
        switch self {
            case .titles(let titles):
                return titles
            default:
                return []
        }
    }
    
    static func parse(_ args: [String]) throws -> [Argument] {
        return try args
            .enumerated()
            .compactMap({ (index, value) in
                var params = getParams(from: args, forArgIndex: index)
                switch value {
                case "--test":
                    return .test
                case "--block-tag":
                    params = params.map({ "[\($0)]" })
                    guard let blockTag = params.first else {
                        throw ArgumentError.missingParam("Please set commit tag without '[]'")
                    }
                    return .blockTag(name: blockTag)
                case "--branch":
                    guard let branch = params.first else {
                        throw ArgumentError.missingParam("Please provide branch name as parameter")
                    }
                    return .branch(name: branch)
                case "--save":
                    guard let fileName = params.first else {
                        throw ArgumentError.missingParam("Please provide file name for saving the changelog")
                    }
                    return .save(fileName: fileName)
                case "--all":
                    return .all
                case "--tags":
                    guard !params.isEmpty else {
                        throw ArgumentError.missingParam("Please provide tags")
                    }
                    return .tags(params)
                case "--titles":
                    guard !params.isEmpty else {
                        throw ArgumentError.missingParam("Please provide titles")
                    }
                    let titles = params.map({ $0.replacingOccurrences(of: "_", with: " ")})
                    return .titles(titles)
                default:
                    return nil
                }
            })
            .check(tagTitleCheckAlgo)
    }
    
    static func getParams(from args: [String], forArgIndex index: Int) -> [String] {
        guard args.count > index + 1 else {
            return []
        }
        let currentIndex = index + 1
        let param = args[currentIndex]
        
        guard param.first != "-" else {
            return []
        }
        
        return [param] + getParams(from: args, forArgIndex: currentIndex)
    }
    
    static private func tagTitleCheckAlgo(args: [Argument]) throws {
        // (a && b) || a == b
        let hasTags = args.contains(where: { $0.isTags })
        let hasTitles = args.contains(where: { $0.isTitles })
        guard (hasTags && hasTitles) || hasTags == hasTitles else {
            throw ArgumentError.missingTagsOrTitles(tags: hasTags, titles: hasTitles)
        }
        let tags = args.first(where: { !$0.tags.isEmpty })?.tags
        let titles = args.first(where: { !$0.titles.isEmpty })?.titles
        guard tags?.count == titles?.count else {
            throw ArgumentError.tagTitleMismatch(tags: tags, titles: titles)
        }
    }
}

extension Collection where Element == String {
    func parseArguments() throws -> [Argument] {
        return try Array(self).parseArgument()
    }
}

extension Array where Element == String {
    func parseArgument() throws -> [Argument] {
        return try Argument.parse(self)
    }
}

extension Collection {
    func check(_ algo: (Self) throws -> Void) throws -> Self {
        try algo(self)
        return self
    }
}
