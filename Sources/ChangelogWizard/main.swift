#!/usr/bin/swift

import Foundation

class Main {
    let args: [String]
    let fileManager: FileManager
    
    init(args: [String] = CommandLine.arguments, fileManager: FileManager = FileManager()) {
        self.args = Array(args.dropFirst())
        self.fileManager = fileManager
    }
    
//    var isUsingGitTag: Bool {
//        return true
//    }
    
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
            
            let features = commits.taggedCommits(.feature)
            let bugs = commits.taggedCommits(.bug)
            
            let body = getBody(version: version, features: features, bugs: bugs)
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
    
    private func getCommits() throws -> [String] {
        let commitDate: String?
        if let commit: String = Arguments.current.compactMap({
            guard case .commit(let commit) = $0 else {
                return nil
            }
            return commit
            }).first {
            verbosePrint("Commit form Argument:", commit)
            commitDate = try getCommitDate(commit)
            verbosePrint("Commit Date:", commitDate ?? "Not found")
        } else {
            commitDate = try getParentCommitDate()
        }
        
        let commitDump = try GitCommands
            .getCommits(date: commitDate)
            .output()
            .lines()
        
        verbosePrint("CommitDump:", commitDump)
        
        let taggedCommits = commitDump
            .filter({ CommitType.isUsingTags($0) })
       verbosePrint(taggedCommits)
        
        let commitTitles = taggedCommits
            .map({ commit -> String in
                return commit.components(separatedBy: " ")
                    .dropFirst()
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            })
        verbosePrint("Commit Titles", commitTitles)
        
        return commitTitles
    }
    
    private func getParentCommitDate() throws -> String? {
        let parents: [String] = try GitCommands
             .getCommitDetails(commit: nil, format: "raw")
             .output()
             .lines()
             .compactMap({
                 guard $0.contains("parent") else {
                     return nil
                 }
                 
                 return $0.components(separatedBy: " ").last
             })
         verbosePrint("Parents:", parents)
        let oldestCommitDate = try parents
             .compactMap({
                 try getCommitDate($0)
             })
             .oldestDate()
         verbosePrint("Oldest Commit Date", oldestCommitDate ?? "")
        return oldestCommitDate
    }
    
    private func getCommitDate(_ commit: String) throws -> String? {
        try GitCommands.getCommitDetails(commit: commit, format: "%cI")
            .output()
            .lines()
            .first
    }
    
    private func getRange() throws -> String? {
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

func verbosePrint(_ subject: Any...) {
    guard Arguments.current.contains(.verbose) else {
        return
    }
    dump(subject)
}

//MARK: ------------   MAIN   ---------------
let main = Main()
Arguments.parse(CommandLine.arguments)
guard !Arguments.current.contains(.test) else {
    main.test()
    exit(0)
}
main.run()
