//
//  CustomError.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

enum CustomError: LocalizedError {
    case never
    case versionError
    case buildError
    case dateFormatError
    
    var errorDescription: String? {
        switch self {
        case .never:
            return "Never gonna happen"
        case .versionError:
            return "Version Not Found"
        case .buildError:
            return "Build Not Found"
        case .dateFormatError:
            return "Commit date format error"
        }
    }
}
