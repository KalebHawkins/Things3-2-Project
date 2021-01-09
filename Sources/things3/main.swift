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
        abstract: "List available areas, projects, or tasks"
    )
    
    @Flag(name: .shortAndLong, help: "List available areas (sorted alphabetically)") var areas: Bool = false
    @Flag(name: .shortAndLong, help: "List available projects (sorted alphabetically)") var projects: Bool = false
    @Flag(name: .shortAndLong, help: "List available tasks (sorted by creation date)") var tasks: Bool = false
    
    func validate() throws {
        // Make sure that at least on flag is set.
        guard areas || projects || tasks else {
            throw ValidationError("See things3 list -h for usage.")
        }
        
        // Make sure that no more then one flag is set at a time.
        // NOTE: This may be change after some thought but for now I don't want that functionality.
        guard !areas && !projects || !areas && !tasks || !projects && !tasks else {
            throw ValidationError("You can only specify one option at a time.")
        }
    }
    
    func run() throws {
        if areas {
            thingsDB.listAreas()
        }
        if projects {
            thingsDB.listProjects()
        }
        if tasks {
            thingsDB.listTasks()
        }
    }
}

// Export is a subcommand of Things3. This command allows you to export a selected project.
struct Export: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Export allows you to export your projects in a more project manager friendly format."
    )
    
    @Argument(help: "Name of the project to export") var project: String
    @Flag(name: .shortAndLong, help: "Output the project in std output") var stdout: Bool = false
    
    func validate() throws {
        guard stdout else {
            throw ValidationError("See things3 export -h for usage.")
        }
    }
    
    func run() throws {
        if stdout {
            thingsDB.stdout(project: project)
        }
    }
    
}

Things3.main()
