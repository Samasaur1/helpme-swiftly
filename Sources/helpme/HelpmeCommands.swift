import HelpmeLib
import ArgumentParser

@main
struct Helpme: ParsableCommand {
    static let configuration: CommandConfiguration = CommandConfiguration(
        commandName: "helpme", //default
        abstract: "one line desc",
        usage: nil, //default
        discussion: "longer desc",
        version: "1.0.0",
        shouldDisplay: true, //default
        subcommands: [View.self, Create.self, Edit.self, Delete.self, List.self],
        defaultSubcommand: View.self,
        helpNames: nil //default
    )

    struct Options: ParsableArguments {
        @Option(help: "", completion: .directory) var helpmePath = "~/.helpme"
        @Argument(help: "", completion: .custom(Helpme.complete_helpme)) var helpme: String
    }

    private static func complete_helpme(_ words: [String]) -> [String] {
        let dir: String
        if let idx = words.firstIndex(of: "--helpme-path"), words.indices.contains(idx + 1) {
            dir = words[idx + 1]
        } else {
            dir = "~/.helpme"
        }
        let loader = HelpmeLoader(dir: dir)
        return loader.list()
    }

    @OptionGroup var options: Options
    func run() throws {
        let loader = HelpmeLoader(dir: options.helpmePath)
        loader.view(helpme: options.helpme)
    }

    struct View: ParsableCommand {
        @OptionGroup var options: Options
        func run() throws {
            let loader = HelpmeLoader(dir: options.helpmePath)
            loader.view(helpme: options.helpme)
        }
    }
    struct Create: ParsableCommand {
        @OptionGroup var options: Options
        @Option(parsing: .unconditionalSingleValue, help: "") var editor: [String] = []

        func run() throws {
            let loader = HelpmeLoader(dir: options.helpmePath, editor: editor.isEmpty ? nil : editor)
            loader.create(helpme: options.helpme)
        }
    }
    struct Edit: ParsableCommand {
        @OptionGroup var options: Options
        @Option(parsing: .unconditionalSingleValue, help: "") var editor: [String] = []

        func run() throws {
            let loader = HelpmeLoader(dir: options.helpmePath, editor: editor.isEmpty ? nil : editor)
            loader.edit(helpme: options.helpme)
        }
    }
    struct List: ParsableCommand {
        @Option(help: "", completion: .directory) var helpmePath = "~/.helpme"

        func run() throws {
            let loader = HelpmeLoader(dir: helpmePath)
            loader.list().forEach { print($0) }
        }
    }
    struct Delete: ParsableCommand {
        @OptionGroup var options: Options

        func run() throws {
            let loader = HelpmeLoader(dir: options.helpmePath)
            loader.delete(helpme: options.helpme)
        }
    }
}
