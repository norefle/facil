# "init" command

## Description

Console application (fl) have to provide "init" command to be able to create dirs and files.

Syntax:

    fl init ROOT

On "init" fl have to do following:

- (✔) Create root dir: $ROOT/.fl
- (✔) Create subdirs:
`````````````````````````````````````````
        $ROOT/.fl/cards
        $ROOT/.fl/meta
        $ROOT/.fl/boards
        $ROOT/.fl/boards/backlog
        $ROOT/.fl/boards/progress
        $ROOT/.fl/boards/done
`````````````````````````````````````````
- (✔) Create config file with default values: $ROOT/.fl/config

## Acceptance criteria

* fl init ROOT works as described above.
* Unit tests for fl init command return successful result.

