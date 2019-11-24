//
//  Arguments.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

public enum ArgumentError: Error {
    case missingParam(String)
    
    public var localizedDescription: String {
        switch self {
        case .missingParam(let customPart):
            return "Argument needs a parameter. \(customPart)"
        }
    }
}

public enum Argument {
    case test
    case blockTag(name: String?)
    case branch(name: String)
    case save(fileName: String?)
    case tags([String]?)
    case titles([String]?)
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
    
    static func parse(_ args: [String]) throws -> [Argument] {
        return try args
            .enumerated()
            .compactMap({ (index, value) in
                switch value {
                case "--test":
                    return .test
                case "--block-tag":
                    var param = try? getParam(from: args, forArgIndex: index, errorMessage: "Please set commit tag without '[]'")
                    if param != nil {
                        param = "[\(param!)]"
                    }
                    return .blockTag(name: param)
                case "--branch":
                    let param = try getParam(from: args, forArgIndex: index, errorMessage: "Please provide branch name as parameter")
                    return .branch(name: param)
                case "--save":
                    let param = try? getParam(from: args, forArgIndex: index, errorMessage: "Please provide file name for saving the changelog")
                    return .save(fileName: param)
                case "--all":
                    return .all
                // TODO: Implement Tags and Titles
                default:
                    return nil
                }
            })
    }
    
    static func getParam(from args: [String], forArgIndex index: Int, errorMessage: String) throws -> String {
        guard args.count > index + 1 else {
            throw ArgumentError.missingParam(errorMessage)
        }
        let param = args[index + 1]
        guard param.first != "-" else {
            throw ArgumentError.missingParam(errorMessage)
        }
        return param
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
