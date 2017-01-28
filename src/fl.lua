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
Fl.show = require "fl.show"
Fl.help = require "fl.help"
Fl.version = require "fl.version"

-- @param options Command line parser
local function configureOptions(options)
    Options:set_name("fl")
    Options:argument("COMMAND", "command to execute.")
    Options:splat("ARGS", "command dependent arguments.", "", 2)
end

local Handlers = {}
Handlers.create = Fl.create.handler
Handlers.init = Fl.init.handler
Handlers.status = Fl.status.handler
Handlers.help = Fl.help.handler
Handlers.version = Fl.version.handler
Handlers.move = Fl.move.handler
Handlers.show = Fl.show.handler

local Help = {}
Help.create = Fl.create.help
Help.init = Fl.init.help
Help.status = Fl.status.help
Help.help = Fl.help.help
Help.version = Fl.version.help
Help.move = Fl.move.help
Help.show = Fl.show.help

--- Entry point.
-- @param ... command line arguments passed to cli application.
local function main(...)
    configureOptions(Options)

    local arguments = Options:parse()

    if arguments then
        if arguments["COMMAND"] then
            local command = arguments["COMMAND"]
            if not Handlers[command] then
                print("Invalid command: " .. command, "\n")
                Handlers.help(Help.help, "", Help)
                return
            end
            local code, description = Handlers[command](arguments.ARGS[1], arguments.ARGS[2], Help)
            if not code then
                print(description, "\n")
                Handlers.help(command, "", Help)
                return -1
            elseif description then
                print(description)
            end
        end
    end

    return 0
end

--------------------------------------------------------------------------------
return main(...)
