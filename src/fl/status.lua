--[[----------------------------------------------------------------------------
--- @file status.lua
--- @brief fácil cli: status command handler.
----------------------------------------------------------------------------]]--

local Fl = require "facil"

--- Cli wrapper for fl.status command.
-- @return true on success
--         nil, error:string otherwise
local function status()
    local board, description = Fl.status()
    if not board then
        return nil, description
    end

    local first = true
    for _, lane in pairs(board) do
        if not first then
            io.stdout:write("\n")
        else
            first = false
        end
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
    end

    return true
end

--- Returns detailed description (string) help for status command.
local function help()
        return [[
fl status

Shows current status of all boards with tasks on them.
]]
end

return {
    handler = status,
    help = help
}
