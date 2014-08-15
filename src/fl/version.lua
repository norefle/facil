--[[----------------------------------------------------------------------------
--- @file version.lua
--- @brief fácil cli: version command handler.
----------------------------------------------------------------------------]]--

--- Name of fácil.
local FACIL_NAME="fácil"

--- Name of main executable of fácil.
local FACIL_CLI_NAME="fl"

--- Version of fácil.
local FACIL_VERSION="0.0.1"

--- Cli command: fl.version.
-- @param topic Name of help topic (string)
-- @param dictionary Table with help topics { ["topic"] = function() return description:string end }
-- @return true on success
--         nil, error:string otherwise
local function version()
    print(FACIL_CLI_NAME .. ": " .. FACIL_NAME .. " v" .. FACIL_VERSION)
    return true
end

--- Returns detailed description (string) help for init command.
local function help()
    return "Shows the version of fácil and exits."
end

return {
    name = FACIL_NAME,
    cli = FACIL_CLI_NAME,
    version = FACIL_VERSION,
    handler = version,
    help = help
}
