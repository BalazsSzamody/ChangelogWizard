#!/usr/bin/swift

import Foundation

class Main {
    let args: [String]
    let fileManager: FileManager
    
    init(args: [String] = CommandLine.arguments, fileManager: FileManager = FileManager()) {
        self.args = Array(args.dropFirst())
        self.fileManager = fileManager
    }
    
    func test() {
        do {
            print("test")
        } catch {
            print(error)
        }
    }
    
    func run() {
        do {
            let version = try getVersion()
            var commits = try getCommits()
            if let jiraTag = Arguments.current.compactMap({ arg -> String? in
                guard case let .jira(tag) = arg else {
                    return nil
                }
                return tag
            }).first {
                commits = commits.filter({ $0.contains(jiraTag) })
            }
            
            let body = getBody(version: version, commits: commits)
            print(body)
        } catch {
            print(error)
            print(error.localizedDescription)
            print("Run command with --verbose argument for more info")
            exit(1)
        }
    }
    
    private func getVersion() throws -> String? {
        guard !Arguments.current.contains(.noVersion) else {
            return nil
        }
        let isAndroid = Arguments
            .current
            .contains(.android)
        let versionStore: VersionStore = isAndroid ?
            AndroidVersionStore() :
            IOSVersionStore()
        
        return try versionStore.getVersion()
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
        } else if Arguments.current.contains(.all) {
            verbosePrint("Printing all commits")
            commitDate = nil
        } else {
            do {
                commitDate = try getParentCommitDate()
            } catch {
                print(error)
                commitDate = nil
            }
        }
        
        let commitDump = try GitCommands
            .getCommits(date: commitDate)
            .output()
            .lines()
        
        verbosePrint("CommitDump:", commitDump)
        
        
        let commitTitles = commitDump
            .map({ commit -> String in
                return commit.components(separatedBy: " ")
                    .dropFirst()
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            })
        verbosePrint("Commit Titles", commitTitles)
        let mergeCommitsRemoved = commitTitles
            .filter({ !$0.contains("Merge branch") })
        let duplicatesRemoved = mergeCommitsRemoved.removingDuplicates()
        verbosePrint("No Duplicates:", duplicatesRemoved)
        return duplicatesRemoved
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
    
    private func getBody(version: String?, commits: [String]) -> String {
        var body = version ?? ""
        let features = commits.taggedCommits(.feature)
        let bugs = commits.taggedCommits(.bug)
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
        
        if bugs.isEmpty && features.isEmpty {
            let generalTitle = CommitType.general.title
            body += """
                    
                    \(generalTitle)
                    \(commits.joined(separator: "\n"))
                    
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
