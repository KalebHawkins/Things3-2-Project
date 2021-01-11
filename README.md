# Things3-2-Project

## Overview 

Things3 is a command line tool to export projects in a more project manager friendly format for those projects you need to share. 

## Installation

To compile the code you need to clone the repository and run the `swift build` command

```shell
git clone https://github.com/KalebHawkins/Things3-2-Project.git
cd Things-2-Project/

swift build --configuraion release
sudo cp .build/release/things3 /usr/local/bin
```

## Usage

### Getting Help

The below commands are all way of getting help. 

```
things3
things3 -h
things3 --help

# EXAMPLE OUTPUT
OVERVIEW: Things3 is a command line interface for exporting projects and tasks in a sharable manner.

Things3 is a command line interface to interact with the Things3 database.

USAGE: things3 <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  list                    List available areas, projects, or tasks
  export                  Export allows you to export your projects in a more project manager friendly format.

  See 'things3 help <subcommand>' for detailed help.
```

You can also get help on subcommands using the same method above but specifying the subcommand.

```
things3 export
things3 export -h
```

### Listing 

Listing  areas, projects, and tasks can be done using the options listed for the `list` subcommand

```
# Will list areas
things3 list areas

# Will list projects
things3 list projects

# Will list tasks
things3 list tasks
```

### Exporting Projects

To display a quick list of project task in your console window use the `export stdout` subcommand.

```
things3 export stdout <projectName>


# Example Output
╒═══════════════╤══════════════════════════════════════════════════════════════════════════════╤══════════════════════════╤════════════╤══════════╤═════════════════╤
│ Creation Date │ Task                                                                         │ Notes                    │ Start Date │ Due Date │ Completion Date │
╞═══════════════╪══════════════════════════════════════════════════════════════════════════════╪══════════════════════════╪════════════╪══════════╪═════════════════╤
│ 2020-10-20    │ Do the things with the stuff                                                 │                          │ N/a        │ N/a      │ 2020-11-04      │
├───────────────┼──────────────────────────────────────────────────────────────────────────────┼──────────────────────────┼────────────┼──────────┼─────────────────┼
│ 2020-10-20    │ More things with more stuff                                                  │                          │ N/a        │ N/a      │ N/a             │
├───────────────┼──────────────────────────────────────────────────────────────────────────────┼──────────────────────────┼────────────┼──────────┼─────────────────┼
│ 2020-10-21    │ Look busy                                                                    │                          │ N/a        │ N/a      │ 2020-11-19      │ 
├───────────────┼──────────────────────────────────────────────────────────────────────────────┼──────────────────────────┼────────────┼──────────┼─────────────────┼
```

To export your project to csv file use `export csv` subcommand.

```
things3 export csv <projectName> <fileName>.csv
```
