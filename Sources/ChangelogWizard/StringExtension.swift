//
//  StringExtension.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

extension String {
    func prependToFile(_ fileName: String) throws {
        guard var url = URL(string: "file://\(FileManager().currentDirectoryPath)") else {
            throw CustomError.never
        }
        
        url = url.appendingPathComponent(fileName)
        var body = self
        if let currentContent = try? String(contentsOf: url) {
            body += "\n\n" + currentContent
        }
        
        try body.write(to: url, atomically: true, encoding: .utf8)
    }
    
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
    
    func lines() -> [String] {
        components(separatedBy: "\n")
    }
    
    func dropFrontDash() -> String {
        guard self.first == "-" else {
            return self
        }
        return String(dropFirst(1))
            .dropFrontDash()
    }
}
