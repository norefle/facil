--[[----------------------------------------------------------------------------
--- @file fl.lua
--- @brief Cli application of fácil task/card system.
----------------------------------------------------------------------------]]--

local Options = require "cliargs"

local Fl = {}
Fl.create = require "fl.create"
Fl.init = require "fl.init"
Fl.status = require "fl.status"
Fl.move = require "fl.move"
Fl.help = require "fl.help"
Fl.version = require "fl.version"

-- @param options Command line parser
local function configureOptions(options)
    Options:set_name("fl")
    Options:add_argument("COMMAND", "command to execute.")
    Options:optarg("ARGS", "command dependent arguments.")
end

local Handlers = {}
Handlers.create = Fl.create.handler
Handlers.init = Fl.init.handler
Handlers.status = Fl.status.handler
Handlers.help = Fl.help.handler
Handlers.version = Fl.version.handler
Handlers.move = Fl.move.handler

local Help = {}
Help.create = Fl.create.help
Help.init = Fl.init.help
Help.status = Fl.status.help
Help.help = Fl.help.help
Help.version = Fl.version.help
Help.move = Fl.move.help

--- Entry point.
-- @param ... command line arguments passed to cli application.
local function main(...)
    configureOptions(Options)
    local help = Options:print_help(true)
    local usage = Options:print_usage(true)

    local arguments = Options:parse_args()

    if arguments then
        if arguments["COMMAND"] then
            local command = arguments["COMMAND"]
            if not Handlers[command] then
                Handlers.help(command, Help)
                print("Invalid command: " .. command)
                return
            end
            local code, description = Handlers[command](arguments.ARGS, Help)
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
