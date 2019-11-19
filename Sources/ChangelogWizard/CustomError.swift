//
//  CustomError.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

enum CustomError: Error {
    case never
    case versionError
    case buildError
    
    var localizedDescription: String {
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
