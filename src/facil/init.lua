--[[----------------------------------------------------------------------------
--- @file init.lua
--- @brief Entry point of fácil module.
----------------------------------------------------------------------------]]--

local FileSystem = require "lfs"
local Uuid = require "uuid"

local Template = {}
Template.Md = require "facil.template.md"

local _M = {}

--- Generates full path inside .fl for card or meta files.
-- @param root Root folder of file inside .fl ("cards", "meta") as string.
-- @param prefix Name of subfolder inside the root as string.
-- @return string with full path with trailing / on success, nil otherwise
local function generatePath(root, prefix)
    assert(root and "string" == type(root))
    assert(prefix and "string" == type(prefix))

    local pwd = FileSystem.currentdir()
    if not pwd then
        return nil
    end

    --local fullName = { pwd, "/.fl/", root, "/", prefix, "/", name }
    return table.concat{ pwd, "/.fl/", root, "/", prefix, "/" }
end

--- Creates directories, files for card or metadata.
-- @param root Root directory of created file ("crads" | "meta").
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
    data.name = data.path .. infix

    if suffix and "" ~= suffix then
        data.name = data.name .. suffix
    end

    if not lfs.attributes(data.path)
        and not lfs.mkdir(data.path)
    then
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
-- @retval true, nil - on success.
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

    return true
end

--- Current version.
_M.VERSION = "0.0.1"

--- Official name of fácil.
_M.NAME = "fácil"

return _M
