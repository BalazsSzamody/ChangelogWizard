//
//  VersionStore.swift
//  
//
//  Created by Balázs Szamódy on 3/7/20.
//

import Foundation

protocol VersionStore {
    func getVersion() throws -> String
}

class IOSVersionStore: VersionStore {
    func getVersion() throws -> String {
        // Get Version from AGVTool
        var command = ["xcrun agvtool what-marketing-version"]
        var version: [String] = []
        guard let v = try Process
            .shell(command)
            .components(separatedBy: "\"")
            .dropFirst().first else {
                throw CustomError.versionError
        }
        version.append(v)
        
        // Get Build from AGVTool
        command = ["xcrun agvtool what-version"]
        guard let build = try Process.shell(command)
            .components(separatedBy: "\n")
            .dropFirst()
            .first?
            .replacingOccurrences(of: " ", with: "") else {
                throw CustomError.buildError
        }
        version.append("(\(build))")
        
        return "# v\(version.joined())\n"
    }
}

class AndroidVersionStore: VersionStore {
    static let kPackageName = "CW_ANDROID_PACKAGE"
    enum AndroidVersionError: LocalizedError {
        case packageName
        case versionComponents
        
        var errorDescription: String? {
            switch self {
            case .packageName:
                return """
                Error: Android Package Name not set.
                
                Set the android package name as `\(AndroidVersionStore.kPackageName)` environment variable.
                """
            case .versionComponents:
                return "Either versionCode or versionName is not found."
            }
        }
    }
    func getVersion() throws -> String {
        
        guard let package = ProcessInfo.processInfo.environment[AndroidVersionStore.kPackageName],
            !package.isEmpty else {
            throw AndroidVersionError.packageName
        }
        
//        "com.sentia.vis.dev"
        let commandTemplate = "adb shell dumpsys package \(package) | grep %@"
        let commandVariants = ["versionName", "versionCode"]
        let output = try commandVariants
            .map({
                let command = String(format: commandTemplate, $0)
                verbosePrint("Command:", command)
                return command
            })
            .map({
                try Process.shell([$0])
            })
        verbosePrint("Output:", output)
        
        let results = output
            .compactMap({
                $0.split(separator: " ")
                    .first?
                    .split(separator: "=")
                    .last?
                    .replacingOccurrences(of: "\n", with: "")
            })
            .map({
                String($0)
            })
        verbosePrint("Version and Build NUmber:", results)
        guard results.count == 2 else {
            throw AndroidVersionError.versionComponents
        }
        
        return "# v\(results[0])(\(results[1]))"
    }
}
