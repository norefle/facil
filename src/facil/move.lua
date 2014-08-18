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

--- Moves card to the next lane.
function _M.move(id, lane)
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
                if task.id:match(id .. ".*") then
                    if found then
                        -- There are two tasks with the same id prefix.
                        -- @todo Raise the error here.
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

    if not lane and currentLane < #boards then
        lane = boards[currentLane + 1].name
    end

    if not lane then
        -- @todo process moving without lane name in case of task in final lane.
    end

    local from = Core.path(boards[currentLane].path, fullId)
    local to = replaceBoard(from, lane)

    return os.rename(from, to)
end



return _M
