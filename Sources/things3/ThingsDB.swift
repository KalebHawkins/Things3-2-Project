//
//  File.swift
//  
//
//  Created by Kaleb Hawkins on 10/22/20.
//

import Foundation
import SQLite
import TextTable

fileprivate enum TaskType: Int64 {
    case task = 0
    case project = 1
    case actionGroup = 2
}

struct Task: CustomStringConvertible {
    var creationDate: String
    var title: String
    var notes: String
    var startDate: String
    var dueDate: String
    var stopDate: String
    
    var description: String {
        "\(creationDate), \(title), \(notes.replacingOccurrences(of: "\n", with: " ")), \(startDate), \(dueDate), \(stopDate)"
    }
}

struct ThingsDB {
    
    private let dbPath: String
    private let thingsdb: Connection
    
    init() {
        guard let homeDir = ProcessInfo.processInfo.environment["HOME"] else {
            fatalError("unable to find user home directory")
        }
        
        dbPath = "\(homeDir)/\(Constants.thingsDatabasePath)"
        
        do {
            thingsdb = try Connection(dbPath)
        } catch {
            fatalError("unable to connect to \(homeDir)/\(Constants.thingsDatabasePath)")
        }
    }
        
}

// MARK: - Database helper function are in this section.
extension ThingsDB {
    fileprivate func run(query: Table) -> [Row] {
        var rows = [Row]()
        
        do {
            for row in try thingsdb.prepare(query) {
                rows.append(row)
            }
        } catch {
            print("there was a problem running the query: \(error)")
        }
        
        return rows
    }
    
    fileprivate func formatDate(from epoch: TimeInterval?) -> String? {
        guard let epochTime = epoch else {
            return nil
        }
        
        // Things3 timestamps things using epoch timestamps.
        // This is what SQLite considers a REAL value type and in Swift that is the same as a Double or floating point type.
        // To handle that we can take the Double and convert it to a date by casting then
        // using the date formatter and then converting that date into a string value
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
    
        let date = Date(timeIntervalSince1970: epochTime)
        return df.string(from: date)
    }
    
    fileprivate func getTasks(for project: String) -> [Task] {
        let tasks = Table("TMTask")
        
        // Creation Date:   Date the task was created
        // Title:           Name of the task
        // Notes:           The notes attached to the task
        // Start Date:      The date the task should be started
        // Due Date:        The deadline for the task to be complete
        // Stop Date:       The date the task was completed
        
        // NOTE: All the dates are handled as epoch time stamps. The wrapper, formatDate(TimeInterval?) -> String? function to handle the conversion
        // from epoch to a date string.
        
        
        // The columns listed here are used in the final output
        let creationDate = Expression<Double>("creationDate")
        let title = Expression<String>("title")
        let notes = Expression<String>("notes")
        let startDate = Expression<Double?>("startDate")
        let dueDate = Expression<Double?>("dueDate")
        let stopDate = Expression<Double?>("stopDate")
        
        // Columns used to manipulate data for the desired output
        // UUID: is the Project UUID
        // parentProject: is the Project the task resides in
        // actionGroup: is the Project section header
        
        let uuid = Expression<String>("uuid")
        let parentProject = Expression<String?>("project")
        let actionGroup = Expression<String?>("actionGroup")
        
        // Get the project uuid from the name of the project.
        // The UUID is used to create a filter for tasks specific to the targeted project
        var projectUuid: String = ""
        do {
            for targetProject in try thingsdb.prepare(tasks.select(uuid).filter(title == project).limit(1)) {
                projectUuid = targetProject[uuid]
            }
        } catch {
            print("failed to retrieve project: \(project): \(error)")
        }

        // Save ALL tasks in an array to filter on.
        // TODO: - Find a better way to do this. With a large dataset this could be really slow.
        var allTasks = [Row]()
        do {
            allTasks = Array(try thingsdb.prepare(tasks))
        } catch {
            fatalError("failed to retrieve tasks for project \(project)")
        }
        
        var sectionHeaders = [Row]()
        var projectTasks = [Row]()
        
        // Filter all project sections
        sectionHeaders = allTasks.filter { (row) -> Bool in
            guard let parentProject = row[parentProject] else {
                return false
            }
            
            if parentProject == projectUuid {
                return true
            }
            
            return false
        }
        
        // Filter all project tasks.
        projectTasks = allTasks.filter { (row) -> Bool in
            if sectionHeaders.contains(where: { row[actionGroup] == $0[uuid] }) {
                return true
            } else if row[uuid] == projectUuid {
                return true
            }
            
            return false
        }
        
        
        // Print task info
        var gatheredTasks = [Task]()
        for sectionHeader in sectionHeaders {
            for projectTask in projectTasks.filter({ $0[actionGroup] == sectionHeader[uuid] }) {
                var startDateStr: String?
                var dueDateStr: String?
                var stopDateStr: String?

                if let startDate = projectTask[startDate] {
                    startDateStr = formatDate(from: TimeInterval(startDate))
                }
                
                if let dueDate = projectTask[dueDate] {
                    dueDateStr = formatDate(from: TimeInterval(dueDate))
                }
                   
                if let stopDate = projectTask[stopDate] {
                    stopDateStr = formatDate(from: TimeInterval(stopDate))
                }
                
                let creationDateStr = formatDate(from: TimeInterval(projectTask[creationDate]))
                
                
                gatheredTasks.append(Task(creationDate: creationDateStr ?? "N/a", title: projectTask[title], notes: projectTask[notes].trimmingCharacters(in: CharacterSet.newlines), startDate: startDateStr ?? "N/a", dueDate: dueDateStr ?? "N/a", stopDate: stopDateStr ?? "N/a"))
            }
        }
        
        return gatheredTasks
    }
}


// MARK: - List subcommand functions are in this section.
extension ThingsDB {
    func listAreas() {
        let areas = Table("TMArea")
        let title = Expression<String>("title")
        
        let query = areas.select(title).order(title.asc)
        
        for area in run(query: query) {
            print(area[title])
        }
    }
    
    func listProjects() {
        let projects = Table("TMTask")
        let title = Expression<String>("title")
        let type = Expression<Int64>("type")
        
        let query = projects.select(title).filter(type == TaskType.project.rawValue).order(title.asc)
        
        for project in run(query: query){
            print(project[title])
        }
    }
    
    func listTasks() {
        
        let tasks = Table("TMTask")
        let title = Expression<String>("title")
        let type = Expression<Int64>("type")
        let trashed = Expression<Int64>("trashed")
        
        // Thing3 stores there dates as epoch time
        let creationDate = Expression<Double>("creationDate")
        
        let query = tasks.select(title,creationDate).filter(type == TaskType.task.rawValue && trashed == 0).order(creationDate.asc)
        
        for task in run(query: query) {
            let dateStr = formatDate(from: TimeInterval(task[creationDate]))
            
            print("\(dateStr!): \(task[title])")
        }
    }
    
    func getTaskTextTable() -> TextTable<Task> {
        let table = TextTable<Task> {
            [Column(title: "Creation Date", value: $0.creationDate),
             Column(title: "Task", value: $0.title),
             Column(title: "Notes", value: $0.notes, width: 24, truncate: .tail),
             Column(title: "Start Date", value: $0.startDate),
             Column(title: "Due Date", value: $0.dueDate),
             Column(title: "Completion Date", value: $0.stopDate)]
        }
        
        return table
    }
}

// MARK: - This section is for export commands
extension ThingsDB {
    
    // stdout is the things3 export --stdout option. This displays a table of
    // text directly to the console.
    func stdout(project: String) {
        var gatheredTasks = getTasks(for: project)
        
        gatheredTasks.sort(by: {$0.startDate < $1.startDate})
        
        let table = getTaskTextTable()
        table.print(gatheredTasks, style: Style.fancy)
    }
    
    // TODO: - Export tasks to CSV formatted file
    func csv(project: String, fileName: String){
        var gatheredTask = getTasks(for: project)
        
        gatheredTask.sort(by: {$0.startDate < $1.startDate})
        
        var taskString = "Creation Date, Title, Notes, Start Date, Due Date, Completion Date\n"
        for task in gatheredTask {
            taskString.append("\(task.description)\n")
        }
        
        do {
            try taskString.write(toFile: fileName, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("failed to create file: \(fileName)")
        }
    }
}
