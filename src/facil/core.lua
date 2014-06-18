--[[----------------------------------------------------------------------------
--- @file core.lua
--- @brief Core component of fácil.
----------------------------------------------------------------------------]]--

local FileSystem = require "lfs"
local Uuid = require "uuid"

local Template = {}
Template.Md = require "facil.template.md"
Template.Config = require "facil.template.default_config"

local _M = {}

--- @brief Finds root directory of fácil.
-- It searched from current directory to its parents up to file system root.
-- If .fl was found either current directory or in parent directory
-- then it will return full path to directory contained .fl.
-- Otherwise it will return nil
-- @return Full path to .fl directory on success, nil otherwise.
local function findFlRoot()
    --- @warning Not implementd yet
    return FileSystem.currentdir()
end

--- Generates full path inside .fl for card or meta files.
-- @param root Root folder of file inside .fl ("cards", "meta", "boards") as string.
-- @param prefix Name of subfolder inside the root as string.
-- @return string with full path with trailing / on success, nil otherwise
local function generatePath(root, prefix)
    local pwd = FileSystem.currentdir()
    if not pwd then
        return nil
    end

    local path = { pwd, ".fl" }
    if root and "" ~= root then
        path[#path + 1] = root
    end
    if prefix and "" ~= prefix then
        path[#path + 1] = prefix
    end

    return table.concat(path, "/")
end

--- Creates directory if doesn't exist.
-- @param path Path to create directory
-- @return true on success, false otherwise.
local function createDir(path)
    return ("directory" == FileSystem.attributes(path, "mode"))
        or FileSystem.mkdir(path)
end

--- Creates directories, files for card or metadata.
-- @param root Root directory of created file ("crads" | "meta" | "boards").
-- @param prefix Name prefix, used to create directory.
-- @param infix Name infix, used to create file name.
-- @param suffix Name suffix, used to create file extension. (optional)
-- @param content Content of created file.
-- @return {path, name} - description of created file on success,
--         nil, string  - description of error otherwise.
local function createCardFile(root, prefix, infix, suffix, content)
    local data = {}

    data.path = generatePath(root, prefix)
    if not data.path then
        return nil, "Can't generate file name for card."
    end

    local fullName = { data.path }

    if infix and "" ~= infix then
        fullName[#fullName + 1] = infix
    end
    data.name = table.concat(fullName, "/")

    if suffix and "" ~= suffix then
        data.name = data.name .. suffix
    end

    if not createDir(data.path) then
        return nil, "Can't create dir: " .. data.path
    end

    local file = io.open(data.name, "w")
    if not file then
        return nil, "Can't create file: " .. tostring(data.name)
    end

    file:write(content)
    file:close()

    return data
end

--- Serializes lua card table to meta file format.
-- @param card Card description {name, dat, id}
-- @todo Use either proper serialization lib or json lib.
-- @return serialized card as string on success, nil otherwise.
local function serializeMeta(card)
    if not card or "table" ~= type(card) then
        return nil
    end

    local meta = {
        [[return {]],
        [[    id = "]] .. card.id .. [[",]],
        [[    name = "]] .. card.name .. [[",]],
        [[    created = ]] .. tostring(card.time),
        [[}]]
    }

    return table.concat(meta, "\n")
end

--- Creates new card
-- @param name Short descriptive name of card.
-- @retval true, string - on success, where string is the uuid of new card.
-- @retval nil, string - on error, where string contains detailed description.
function _M.create(name)
    if not name or "string" ~= type(name) then
        return nil, "Invalid argument."
    end

    local card = {}

    card.name = name
    card.id = uuid.new()
    if not card.id then
        return nil, "Can't generate uuid for card."
    end

    card.time = os.time()

    local prefix = card.id:sub(1, 2)
    local body = card.id:sub(3)

    local markdown, markdownErr
        = createCardFile("cards", prefix, body, ".md", Template.Md.value)
    if not markdown then
        return nil, markdownErr
    end

    --- @warning Platform (linux specific) dependent code.
    --- @todo Either replace with something more cross platform
    ---       or check OS before.
    os.execute("$EDITOR " .. markdown.name)

    local meta, metaErr
        = createCardFile("meta", prefix, body, nil, serializeMeta(card))
    if not meta then
        return nil, metaErr
    end

    local marker, markerErr = createCardFile("boards", "backlog", card.id, nil, tostring(card.time))
    if not marker then
        return nil, markerErr
    end

    return true, card.id
end

--- Initialized fácil's file system layout inside selected directory.
-- @param root Path to the root directory, where to initialize fl.
-- @retval true - on success
-- @retval nil, string - on error, where string contains detailed description.
function _M.init(root)
    if not root or "string" ~= type(root) then
        return nil, "Invalid argument."
    end

    local directories = {
        root .. "/.fl",
        root .. "/.fl/boards",
        root .. "/.fl/boards/backlog",
        root .. "/.fl/boards/progress",
        root .. "/.fl/boards/done",
        root .. "/.fl/cards",
        root .. "/.fl/meta"
    }

    for _, path in pairs(directories) do
        if not createDir(path) then
            return nil, "Can't create directory: " .. path
        end
    end

    local configSuccess, configError =
        createCardFile("", nil, "config", nil, Template.Config.value)
    if not configSuccess then
        return nil, configError
    end

    return true
end

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

    local root = findFlRoot()
    if not root then
        return nil, "It's not a fácil board."
    end

    for laneName in lfs.dir(root .. "/boards") do
        if "." ~= laneName
            and ".." ~= laneName
            and "directory" == lfs.attributes(laneName, "mode")
        then
            -- @todo Sort boards in order of inital -> intermediate -> finish
            --       Get all these information from config file.
            local lane = { name = laneName, tasks = { } }
            local laneRoot = table.concat{root, "/boards/", laneName}
            for taskId in lfs.dir(laneRoot) do
                if "file" == lfs.attributes(taskId, "mode") then
                    -- @todo Fill task with proper values.
                    local task = {
                        id = taskId,
                        name = "",
                        created = 0,
                        moved = 0
                    }
                    lane.tasks[#lane.tasks + 1] = task
                end
            end
            board[#board + 1] = lane
        end
    end

    return board
end

return _M
