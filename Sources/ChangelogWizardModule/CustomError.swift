//
//  CustomError.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

public enum CustomError: Error {
    case never
    case versionError
    case buildError
    
    public var localizedDescription: String {
        switch self {
        case .never:
            return "Never gonna happen"
        case .versionError:
            return "Version Not Found"
        case .buildError:
            return "Build Not Found"
        }
    }
}

public extension Error {
    func nsError() -> NSError {
        var message: String
        switch self {
        case let error as CustomError:
            message = error.localizedDescription
        case let error as ArgumentError:
            message = error.localizedDescription
        default:
            message = self.localizedDescription
        }
        let nsError = self as NSError
        return NSError(domain: nsError.domain, code: nsError.code, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    func fullDescription() -> String {
        return nsError().localizedDescription
    }
}
