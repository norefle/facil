--[[----------------------------------------------------------------------------
--- @file show.lua
--- @brief fácil cli: show command handler.
----------------------------------------------------------------------------]]--

local Fl = require "facil"

-- @return true on success
--         nil, error:string otherwise
local function show(id)
    return Fl.show(id)
end

--- Returns detailed description (string) help for status command.
local function help()
        return [[
fl show TASK

Shows content of the TASK.
]]
end

return {
    handler = show,
    help = help
}
