//
//  ProcessExtension.swift
//  
//
//  Created by Balazs Szamody on 19/11/19.
//

import Foundation

extension Process {
    @discardableResult
    static func shell(_ commands: [String]) throws -> String {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", commands.joined(separator: " ")]
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
