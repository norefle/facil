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
    Options:add_flag("-v, --version", "prints version and exits.")
end

local handler = {}

handler.version = function()
    print(FACIL_CLI_NAME .. ": " .. FACIL_NAME .. " v" .. FACIL_VERSION)
end

--- Entry point.
-- @param ... command line arguments passed to cli application.
local function main(...)
    configureOptions(Options)

    local arguments = Options:parse_args()

    if arguments then
        for key, value in pairs(arguments) do
            if value and handler[key] then
                handler[key]()
            end
        end
    end
end

--------------------------------------------------------------------------------
main(...)
