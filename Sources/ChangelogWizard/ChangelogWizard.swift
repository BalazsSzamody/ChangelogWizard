//
//  ChangelogWizard.swift
//  
//
//  Created by Balazs Szamody on 24/11/19.
//

import Foundation

public class ChangelogWizard {
    public let args: [Argument]
    let fileManager: FileManager
    let gitService: GitService
    
    init(args: [String] = CommandLine.arguments, fileManager: FileManager = FileManager(),
         gitService: GitService = GitServiceImp()) throws {
        self.args = try args.dropFirst().parseArguments()
        self.fileManager = fileManager
        self.gitService = gitService
    }
    
    public convenience init(_ args: [String]) throws {
        try self.init(args: args)
    }
    
    var isUsingBlockTag: Bool {
        return args.contains(where: { $0.isBlockTag })
    }
    
    var isAll: Bool {
        return args.contains(where: { $0.isAll })
    }
    
    public func test() throws {
        let body = getBody(version: "# v1.1.1", features: ["- Test1", "- Test 2"], bugs: ["- Test1", "- Test 2"])
        print(body)
    }
    
    public func run() throws {
        let version = try getVersion()
        var commits = try getCommits()
        
        if let blockTag = args.first(where: { $0.isBlockTag }),
            case .blockTag(let tag) = blockTag {
            commits = commits.commitsSinceLast(tag ?? "[AUTO]")
        }
        
        let features = commits.taggedCommits(.feature)
        let bugs = commits.taggedCommits(.bug)
        
        let body = getBody(version: version, features: features, bugs: bugs)
        
        if let saveTag = args.first(where: { $0.isSave}),
            case .save(let fileName) = saveTag {
            try body.prependToFile(fileName ?? "changelog.md")
        }
        print(body)
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
        
        if isUsingBlockTag {
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
        var branch: String?
        if let branchArg = args.first(where: { $0.isBranch}),
            case .branch(let branchName) = branchArg {
            branch = branchName
        }
        
        let commitDump = try gitService
            .getCommits(branch: branch, range: try getGitTagRange())
            .components(separatedBy: "\n")
            .filter({ $0.isUsingTags(
                CommitType
                    .allCases
                    .map({ $0.tag })
                )
            })
            // Get Commit message only
            .map({ commit -> String in
                return commit.components(separatedBy: ":")
                    .dropFirst()
                    .joined(separator: ":")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            })
        return commitDump
    }
    
    private func getGitTagRange() throws -> String? {
        guard isUsingBlockTag || isAll else {
            return nil
        }
        let tag = try gitService
            .getLastTag()
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
