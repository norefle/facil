# fácil

fácil is a simple local task tracker. All you need is a console
and a fl command to create, read, move tasks.

It supposed to be git friendly. Hence every task is a simple text file
in markdown format. Fl does not care about task editing, file history,
authorship or any other stuff which could be solved by editor, file system
or VCS system. The only thing it cares about is tasks on boards. It responsible
for creating, moving, showing tasks and boards status only. That's it.

There are following command:

* *fl init* initializes fácil in a selected dir.
* *fl create* creates new task, all required meta files and places new task
  onto initial board (*backlog*).
* *fl status* shows current status of the boards.
* *fl move* moves tasks from board to board.
* *fl help* shows help for selected command.

fácil itself uses fácil for task tracking (look at .fl/cards in a root dir).

# TL;DR

It's pretty stupid and simple terminal oriented task tracker useful
for individuals or small dev teams.

# Notice

The project currently is far from "ready to use in everyday work"
and still in a heavy development phase.

# Dependencies

* [cli_args](https://github.com/amireh/lua_cliargs) for fl cli application.
* [luuid](http://www.tecgraf.puc-rio.br/~lhf/ftp/lua/#luuid) for task id generation.
* [luafilesystem](http://keplerproject.github.io/luafilesystem/) for file system routines.
* [busted](http://olivinelabs.com/busted/) for unit tests.
