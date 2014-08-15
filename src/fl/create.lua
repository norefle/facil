--[[----------------------------------------------------------------------------
--- @file create.lua
--- @brief fácil cli: create command handler.
----------------------------------------------------------------------------]]--

local Fl = require "facil"

--- Cli wrapper for fl.create command.
-- @param name Name of the created task (string)
-- @return true on success
--         nil, error:string otherwise
local function create(name)
    if not name then
        return nil, "Error: name should be non empty to create card."
    end

    return Fl.create(name)
end

--- Returns detailed description (string) help for create command.
local function help()
        return [[
fl create NAME

Creates new card

Card consists of three files:
  1 Card file - text file with markdown content contained description of task.
  2 Meta data file - text file in lua format with meta data described card itself.
  3 Status file - empty file in boards pointed to current status of the card.
All these files are placed inside .fl directory (by default).
]]
end

return {
    handler = create,
    help = help
}
