--[[----------------------------------------------------------------------------
--- @file init.lua
--- @brief Entry point of fácil module.
----------------------------------------------------------------------------]]--

local FileSystem = require "lfs"
local Uuid = require "uuid"

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

    local markdown = {}

    markdown.path = generatePath("cards", prefix)
    if not markdown.path then
        return nil, "Can't generate file name for card."
    end
    markdown.name = markdown.path .. body .. ".md"

    if not lfs.attributes(markdown.path)
        and not lfs.mkdir(markdown.path)
    then
        return nil, "Can't create dir: " .. markdown.path
    end

    markdown.file = io.open(markdown.name, "w")
    if not markdown.file then
        return nil, "Can't create file: " .. tostring(markdown.name)
    end

    markdown.file:close()

    return true
end

--- Current version.
_M.VERSION = "0.0.1"

--- Official name of fácil.
_M.NAME = "fácil"

return _M
