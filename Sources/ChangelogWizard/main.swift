import Foundation

class Main {
    let args: [String]
    
    let fileManager: FileManager
    
    init(args: [String] = CommandLine.arguments, fileManager: FileManager = FileManager()) {
        self.args = Array(args.dropFirst())
        self.fileManager = fileManager
    }
    
    func run() {
        print(FileManager().currentDirectoryPath)
//        shell(args)
    }
    
    @discardableResult
    private func shell(_ commands: [String]) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
//        task.arguments = commandsswift buid
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}

Main().run()
