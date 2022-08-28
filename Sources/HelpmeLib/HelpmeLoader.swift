import Foundation

public struct HelpmeLoader {
    public let dir: String
    public let overrideEditor: [String]?

    public init(dir: String, editor: [String]? = nil) {
        let _dir: String
        if dir.last == "/" {
            _dir = String(dir.dropLast())
        } else {
            _dir = dir
        }
        self.dir = (_dir as NSString).expandingTildeInPath
        self.overrideEditor = editor
    }

    private var effectiveEditor: [String] {
        if let e = overrideEditor { return e }
        if let e = ProcessInfo.processInfo.environment["EDITOR"] { return [e] }
        return ["nano"]
    }

    public func list() -> [String] {
        try! FileManager.default.contentsOfDirectory(atPath: dir).map { $0.dropLast(4) }.map(String.init)
    }

    public func create(helpme: String) {
        FileManager.default.createFile(atPath: dir + "/" + helpme + ".txt", contents: nil)
        edit(helpme: helpme)
    }

    public func edit(helpme: String) {
        var pid: pid_t = 0
        let args = ["/usr/bin/env"] + effectiveEditor + [dir + "/" + helpme + ".txt"]
        let c_args = args.map { $0.withCString(strdup)! }
        posix_spawn(&pid, c_args[0], nil, nil, c_args + [nil], environ)
        waitpid(pid, nil, 0)
    }

    public func delete(helpme: String) {
        try! FileManager.default.removeItem(atPath: dir + "/" + helpme + ".txt")
    }

    public func view(helpme: String) {
        print(try! String(contentsOfFile: dir + "/" + helpme + ".txt"))
    }
}
