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

    for laneName in Core.lfs.dir(Core.path(root, "boards")) do
        if "." ~= laneName
            and ".." ~= laneName
            and "directory" == Core.lfs.attributes(Core.path(root, "boards", laneName), "mode")
        then
            -- @todo Sort boards in order of inital -> intermediate -> finish
            --       Get all these information from config file.
            local lane = { name = laneName, tasks = { } }
            local laneRoot = Core.path(root, "boards", laneName)
            for taskId in Core.lfs.dir(laneRoot) do
                if "file" == Core.lfs.attributes(Core.path(laneRoot, taskId), "mode") then
                    local metaFile = Core.path(root, "meta", Core.pathById(taskId))
                    local success, metadata = pcall(
                        dofile,
                        Core.path(root, "meta", Core.pathById(taskId))
                    )
                    -- @todo Fill task with proper values.
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
            board[#board + 1] = lane
        end
    end

    return board
end

return _M
