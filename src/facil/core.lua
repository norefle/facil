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

    local meta = {}
    meta[#meta + 1] = "return {"
    meta[#meta + 1] = "    id = " .. card.id .. ","
    meta[#meta + 1] = "    name = " .. card.name .. ","
    meta[#meta + 1] = "    created = " .. tostring(card.time) .. ""
    meta[#meta + 1] = "}"

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

    local directories = {}
    directories[#directories + 1] = root .. "/.fl"
    directories[#directories + 1] = root .. "/.fl/boards"
    directories[#directories + 1] = root .. "/.fl/boards/backlog"
    directories[#directories + 1] = root .. "/.fl/boards/progress"
    directories[#directories + 1] = root .. "/.fl/boards/done"
    directories[#directories + 1] = root .. "/.fl/cards"
    directories[#directories + 1] = root .. "/.fl/meta"

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

return _M
