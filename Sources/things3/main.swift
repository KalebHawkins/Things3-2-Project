//
//  main.swift
//
//
//  Created by Kaleb Hawkins on 10/22/20.
// This file is the base file defines the command line arguments and subcommands. 


import ArgumentParser

let thingsDB: ThingsDB = ThingsDB()

// Things3 is the root command containing multiple subcommands.
struct Things3: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Things3 is a command line interface for exporting projects and tasks in a sharable manner.",
        discussion: "Things3 is a command line interface to interact with the Things3 database.",
        subcommands: [List.self, Export.self]
    )
}

// List is a subcommand of Things3. This command allows flags to be passed to list available areas, projects, or tasks.
struct List: ParsableCommand {
    
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "List available areas, projects, or tasks",
        subcommands: [Projects.self, Areas.self, Tasks.self]
    )
    
    func run() throws {
        print(List.helpMessage())
    }
}

// Lists projects using things3 list projects
struct Projects: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "List available projects"
    )
    
    func run() throws {
        thingsDB.listProjects()
    }
}

// Lists areas using things3 list areas
struct Areas: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "List available areas"
    )
    
    func run() throws {
        thingsDB.listAreas()
    }
}

// Lists tasks using things3 list tasks
struct Tasks: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "List available tasks"
    )
    
    func run() throws {
        thingsDB.listTasks()
    }
}

// Export is a subcommand of Things3. This command allows you to export a selected project.
struct Export: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Export allows you to export your projects in a more project manager friendly format.",
        subcommands: [Stdout.self, Csv.self]
    )
    
    func run() throws {
        print(Export.helpMessage())
    }
}

// Print project to stdout using things3 export stdout
struct Stdout: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Print your project to stdout"
    )
    
    @Argument(help: "Name of the project to export") var project: String
    
    func run() throws {
        thingsDB.stdout(project: project)
    }
}

// Export project to stdout using things3 export csv <filename>
struct Csv: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Export your project to csv file"
    )
    
    @Argument(help: "Name of the project to export") var project: String
    @Argument(help: "Name of the project to export") var fileName: String
    
    func run() throws {
        thingsDB.csv(project: project, fileName: fileName)
    }
}

Things3.main()
