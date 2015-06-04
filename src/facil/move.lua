--[[----------------------------------------------------------------------------
--- @file move.lua
--- @brief fácil's move command.
----------------------------------------------------------------------------]]--

local Core = require "facil.core"
local status = require("facil.status").status

local _M = {}

--- Replaces board name in a full board path
-- @param path Full path to original board (string).
-- @param board The new board name to put inside the path (string).
-- @return string - new path with replaced board name.
local function replaceBoard(path, board)
    local prefix, oldBoard, postfix = path:match("(.*/.fl/boards/)(.-)(/.+)")
    if not prefix or not oldBoard or not postfix then
        return nil
    end

    return prefix .. board .. postfix
end

--- Encode string to be safe for pattern matching.
-- @param input Input string to encode (string)
-- @return string - encoded string
local function encode(input)
    return input:gsub("%-", "%%%-"):gsub("%*", "%%%*"):gsub("%+", "%%%+"):gsub("%.", "%%%.")
end

--- Moves card to the next lane.
function _M.move(id, laneName)
    if not id or "string" ~= type(id) or "" == id then
        return nil, "Invalid task id: " .. tostring(id)
    end

    local boards = status()
    local found = false
    local currentLane = nil
    local fullId = nil
    for laneIndex, lane in pairs(boards) do
        if lane and lane.tasks then
            for _, task in pairs(lane.tasks) do
                if task.id:match("^" .. encode(id) .. ".*$") then
                    if found then
                        -- There are two tasks with the same id prefix.
                        return nil, "Task id is ambiguous: " .. tostring(id)
                    else
                        found = true
                        currentLane = laneIndex
                        fullId = task.id
                    end
                end
            end
        end
    end

    if not found then
        return nil, "There is no task with id: " .. tostring(id)
    end

    local toIndex
    if laneName then
        local laneExists = false
        for index, lane in pairs(boards) do
            if lane.name == laneName then
                laneExists = true
                toIndex = index
                break
            end
        end
        if not laneExists then
            return nil, "There is no lane with the name '" .. laneName .."'"
        end
    elseif not laneName and currentLane < #boards then
        toIndex = currentLane + 1
        laneName = boards[toIndex].name
    end

    if not laneName then
        return nil, "Task is already on final board: "
                        .. tostring(boards[currentLane].name) .. "/" .. fullId
    end

    local toLane = boards[toIndex]
    if 0 < toLane.wip and toLane.wip == #toLane.tasks then
        return nil, "Lane '" .. toLane.name .. "' is already full: " .. tonumber(toLane.wip)
    end

    local from = Core.path(boards[currentLane].path, fullId)
    local to = replaceBoard(from, laneName)

    return os.rename(from, to)
end

return _M
