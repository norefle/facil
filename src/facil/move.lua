--[[----------------------------------------------------------------------------
--- @file move.lua
--- @brief fácil's move command.
----------------------------------------------------------------------------]]--

local Core = require "facil.core"

local _M = {}

--- Moves card to the next lane.
function _M.move(id, lane)
    if not id or "string" ~= id or "" == id then
        return nil, "Invalid task id: " .. tostring(id)
    end

    return nil, "Not implemented yet."
end



return _M
