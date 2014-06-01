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

handler.help = function(usage, name)
    if not name or "" == name then
        print [[
List of commands:
    help [NAME]       Prints either common or detailed help for command 'name'
    create NAME       Creates new card with selected name.
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
    else
        print(usage)
        print("Error: invalid command name: '" .. tostring(name) .. "'")
        print("Use fl help to show list of supported command.")
    end
end

handler.create = function(usage, name)
    if not name then
        print(usage)
        print("Error: name should be non empty to create card")
    end

    Fl.create(name)
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
            handler[command](usage, arguments.ARGS)
        end
    end
end

--------------------------------------------------------------------------------
main(...)
