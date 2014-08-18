--[[----------------------------------------------------------------------------
--- @file move.lua
--- @brief fácil cli: move command handler.
----------------------------------------------------------------------------]]--

local Fl = require "facil"

--- Cli wrapper for fl.move command.
-- @return true on success
--         nil, error:string otherwise
local function move(id)
    return Fl.move(id)
end

--- Returns detailed description (string) help for status command.
local function help()
        return [[
fl move TASK [LANE]

Moves task (TASK) either to the next lane in order set in config
or to the selected explicitly lane (LANE).

Task could be specified by its full id or partial id.

If partial id was used and there are more then one task with similar partial id
then error would occur.

If task moved to lane with defined WIP (> 0) and current amount of task
was already equal to WIP then error would occur.]]
end

return {
    handler = move,
    help = help
}
