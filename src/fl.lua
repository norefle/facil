--[[----------------------------------------------------------------------------
--- @file fl.lua
--- @brief Cli application of fácil task/card system.
----------------------------------------------------------------------------]]--

local Options = require "cliargs"
local Fl = require "facil"

--- Name of fácil.
local FACIL_NAME="fácil"

--- Name of main executable of fácil.
local FACIL_CLI_NAME="fl"

--- Version of fácil.
local FACIL_VERSION="0.0.1"

--- Configures command line options
-- @param options Command line parser
local function configureOptions(options)
    Options:set_name("fl")
    Options:add_argument("COMMAND", "command to execute.")
    Options:optarg("ARGS", "command dependent arguments.")
    Options:add_flag("-v, --version", "prints version and exits.")
end

local handler = {}
handler.flags = {}

handler.flags.version = function()
    print(FACIL_CLI_NAME .. ": " .. FACIL_NAME .. " v" .. FACIL_VERSION)
end

handler.help = function(name)
    if not name or "" == name then
        print [[
List of commands:
    help [NAME]       Prints either common or detailed help for command 'name'
    init ROOT         Initializes fácil within 'root' directory.
    create NAME       Creates new card with selected name.
    status            Shows current status of board with tasks.
]]
    elseif "create" == name then
        print [[
fl create NAME

Creates new card

Card consists of three files:
  1 Card file - text file with markdown content contained description of task.
  2 Meta data file - text file in lua format with meta data described card itself.
  3 Status file - empty file in boards pointed to current status of the card.
All these files are placed inside .fl directory (by default).
]]
    elseif "init" == name then
        print [[
fl init ROOT

Creates fácil's file system layout inside selected directory and all required files.
File system layout is:
  ROOT/                           - Selected root, passed as root param.
      .fl/                        - Root directory for entire fácil.
          boards/                 - Root directory for boards.
              backlog/            - Initial board, all new tasks are sticked here.
              progress/           - All task which are in progress are sticked here.
              done/               - All finished tasks.
          cards/                  - All tasks ever created.
          meta/                   - Description of tasks.
          config                  - Local configuration file.
]]
    elseif "status" == name then
        print [[
fl status

Shows current status of all boards with tasks on them.
]]
    else
        return nil, "Error: invalid command name: '" .. tostring(name) .. "'"
    end

    return true
end

handler.create = function(name)
    if not name then
        return nil, "Error: name should be non empty to create card."
    end

    return Fl.create(name)
end

handler.init = function(rootPath)
    if not rootPath then
        return nil, "Error: root should be non empty to initialize fácil."
    end

    return Fl.init(rootPath)
end

handler.status = function()
    local board, description = Fl.status()
    if not board then
        return nil, description
    end

    for _, lane in pairs(board) do
        io.stdout:write(
            string.format(
                "[ %3d | %3d ] %s\n",
                #lane.tasks,
                lane.wip,
                lane.name
            )
        )
        for _, task in pairs(lane.tasks) do
            io.stdout:write(
                string.format(
                    "%s %s (%s)\n",
                    os.date("%d.%m.%Y", task.moved),
                    task.name,
                    task.id:sub(1, 8)
                )
            )
        end
        print("\n")
    end

    return true
end

--- Entry point.
-- @param ... command line arguments passed to cli application.
local function main(...)
    configureOptions(Options)
    local help = Options:print_help(true)
    local usage = Options:print_usage(true)

    local arguments = Options:parse_args()

    if arguments then
        for key, value in pairs(arguments) do
            if value and handler.flags[key] then
                handler[key]()
            end
        end
        if arguments["COMMAND"] then
            local command = arguments["COMMAND"]
            if not handler[command] then
                print(help)
                print("Invalid command: " .. command)
                return
            end
            local code, description = handler[command](arguments.ARGS)
            if not code then
                print(usage)
                print(description)
                print("Use either fl help or fl --help for command and general help topics.")
                return -1
            end
        end
    end

    return 0
end

--------------------------------------------------------------------------------
return main(...)
