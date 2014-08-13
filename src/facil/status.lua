--[[----------------------------------------------------------------------------
--- @file create.lua
--- @brief fácil's status command.
----------------------------------------------------------------------------]]--

local Core = require "facil.core"

local _M = {}

--- Returns current status of the board with tasks on it.
-- @return Board description.
-- @note Here is the example of returned board:
--      @code
--          board = {
--              -- Lane number 0, with flag initial = true
--              {
--                  name = "Backlog",
--                  -- Work in progress limit (set in config file)
--                  wip = 12,
--                  -- Board priority (0 means backlog, 100 means done, [1, 99] custom boards)
--                  priority = 0,
--                  tasks = {
--                      -- Array of tasks, ordered by date (asc)
--                      {
--                          name = "Task #1",
--                          id = "aaaa-bbbb-cccc-dddd",
--                          created = 123456789,
--                          moved = 234567890
--                      },
--                      ...
--                  }
--              },
--              ...
--          }
--      @endcode
function _M.status()
    local board = {}

    local root = Core.getRootPath()
    if not root then
        return nil, "It's not a fácil board."
    end

    local hasConfig, config = Core.getConfig(root)
    if not hasConfig then
        return nil, config
    end

    local boardConfig = {}
    config.boards = config.boards or {}
    for _, v in pairs(config.boards) do
        if v.name then
            boardConfig[v.name] = v
        end
    end

    for laneName in Core.lfs.dir(Core.path(root, "boards")) do
        if "." ~= laneName
            and ".." ~= laneName
            and "directory" == Core.lfs.attributes(Core.path(root, "boards", laneName), "mode")
        then
            -- @todo Sort boards in order of inital -> intermediate -> finish
            --       Get all these information from config file.
            local lane = { name = laneName, tasks = { }, wip = 0 }
            if boardConfig[laneName] and boardConfig[laneName].wip then
                lane.wip = boardConfig[laneName].wip
            end

            local laneRoot = Core.path(root, "boards", laneName)
            for taskId in Core.lfs.dir(laneRoot) do
                if "file" == Core.lfs.attributes(Core.path(laneRoot, taskId), "mode") then
                    local success, metadata = Core.readMetadata(root, taskId)
                    if success then
                        local task = {
                            id = taskId,
                            name = metadata.name,
                            created = metadata.created,
                            moved = Core.movedAt(laneName, taskId) or 0
                        }
                        lane.tasks[#lane.tasks + 1] = task
                    end
                end
            end
            -- Sort Task by moving timestamp
            if 0 < #lane.tasks then
                table.sort(lane.tasks, function(left, right)
                    return left.moved < right.moved
                end)
            end
            -- Fill the board
            board[#board + 1] = lane
        end
    end

    return board
end

return _M
