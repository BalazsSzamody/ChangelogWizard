#!/usr/bin/swift

import Foundation

enum CustomError: Error {
    case never
    
    var localizedDescription: String {
        switch self {
        case .never:
            return "Never gonna happen"
        }
    }
}

class Main {
    let args: [String]
    let fileManager: FileManager
    
    init(args: [String] = CommandLine.arguments, fileManager: FileManager = FileManager()) {
        self.args = Array(args.dropFirst())
        self.fileManager = fileManager
    }
    
    func run() {
        do {
            let output = try shell(args)
            print(output)
        } catch {
            print(error)
        }
    }
    
    @discardableResult
    private func shell(_ commands: [String]) throws -> String {
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

Main().run()
