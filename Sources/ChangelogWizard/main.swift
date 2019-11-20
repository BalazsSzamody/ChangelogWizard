#!/usr/bin/swift

import Foundation

class Main {
    let args: [String]
    let fileManager: FileManager
    
    init(args: [String] = CommandLine.arguments, fileManager: FileManager = FileManager()) {
        self.args = Array(args.dropFirst())
        self.fileManager = fileManager
    }
    
    var isUsingGitTag: Bool {
        return args.contains(Arguments.tag.rawValue)
    }
    
    func test() {
        do {
            let body = getBody(version: "# v1.1.1", features: ["- Test1", "- Test 2"], bugs: ["- Test1", "- Test 2"])
            print(body)
        } catch {
            print(error)
        }
    }
    
    func run() {
        do {
            let version = try getVersion()
            var commits = try getCommits()
            
            if !isUsingGitTag {
                commits = commits
                    .commitsSinceLast(.auto)
            }
            
            let features = commits.taggedCommits(.feature)
            let bugs = commits.taggedCommits(.bug)
            
            let body = getBody(version: version, features: features, bugs: bugs)
            
            try body.prependToFile(getFileName())
            print(body)
        } catch {
            print(error)
            exit(1)
        }
    }
    
    private func getVersion() throws -> String {
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
        
        if !isUsingGitTag {
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
        }
        
        return "# v\(version.joined())\n"
    }
    
    private func getCommits() throws -> [String] {
        let commitDump = try GitCommands
            .getCommits(range: try getRange())
            .output()
            .components(separatedBy: "\n")
            .filter({ CommitType.isUsingTags($0) })
            // Get Commit message only
            .map({ commit -> String in
                return commit.components(separatedBy: ":")
                    .dropFirst()
                    .joined(separator: ":")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            })
        return commitDump
    }
    
    private func getRange() throws -> String? {
        guard isUsingGitTag else {
            return nil
        }
        let tag = try GitCommands
            .getLastTag
            .output()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let hasTag = !tag.contains("No names")
        
        guard hasTag else {
            return nil
        }
        
        return "\(tag)..HEAD"
    }
    
    private func getFileName() -> String {
        let tag = args
            .compactMap({ Arguments(rawValue: $0) })
            .first(where: { $0 == .tag })
        return tag?.fileName ?? Arguments.defaultFileName
    }
    
    private func getBody(version: String, features: [String], bugs: [String]) -> String {
        var body = version
        if !features.isEmpty {
            let featuresTitle = CommitType.feature.title
            body += """
                    
                    \(featuresTitle)
                    \(features.joined(separator: "\n"))
                    
                    """
        }
        
        if !bugs.isEmpty {
            let bugsTitle = CommitType.bug.title
            body += """
                    
                    \(bugsTitle)
                    \(bugs.joined(separator: "\n"))
                    
                    
                    """
        }
        
        return body
    }
}

//MARK: ------------   MAIN   ---------------
let main = Main()

guard !CommandLine.arguments.contains("--test") else {
    main.test()
    exit(0)
}
main.run()
