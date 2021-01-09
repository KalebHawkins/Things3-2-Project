# Things3-CLI

## DISCLAIMER
This code repository is a work in progress. 

## Overview 

Things3 is a command line tool to export projects in a more project manager friendly format for those projects you need to share. 


## Usage

### Getting Help

```
./things3 -h
OVERVIEW: Things3 is a command line interface for exporting projects and tasks in a sharable manner.

Things3 is a command line interface to interact with the Things3 database.

USAGE: things3 <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  list                    List available areas, projects, or tasks

  See 'things3 help <subcommand>' for detailed help.
  ```
  
  ###  Listing Areas, Projects, and Tasks
  
  ```
  ./things3 list -h
  OVERVIEW: List available areas, projects, or tasks

  USAGE: things3 list [--area] [--projects] [--tasks]

  OPTIONS:
    -a, --area              List available areas (sorted alphabetically)
    -p, --projects          List available projects (sorted alphabetically)
    -t, --tasks             List available tasks (sorted by creation date)
    -h, --help              Show help information.
```

Listing  areas, projects, and tasks can be done using the options listed for the `list` subcommand

```
# Will list areas
./things3 list -a

# Will list projects
./things3 list -p

# Will list tasks
./things3 list -t
```

### Exporting Projects


More to come....
