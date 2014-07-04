--[[----------------------------------------------------------------------------
--- @file core.lua
--- @brief Core component of fácil.
----------------------------------------------------------------------------]]--

local FileSystem = require "lfs"
local Uuid = require "uuid"

local _M = {}

--- @todo Replace these public exposed libraries with wrappers.
_M.lfs = FileSystem
_M.uuid = Uuid

--- @brief Returns parent directory for selected one.
-- @param current Current directory to get its parent.
-- @return Parent path in success, (nil, string) otherwise.
function _M.getParent(current)
    if not current or "string" ~= type(current) then
        return nil, "Invalid argument: " .. tostring(current)
    end

    local parent, child = current:match("^(.+)/(.+)/?$")
    if not parent then
        return nil, "There is no parent dir for: " .. tostring(current)
    end

    return parent
end

--- @brief Returns root directory of fácil.
--
-- It searches from current directory to its parents up to file system root.
-- If .fl was found either within current directory or within parent directory
-- then it will return full path to directory contained .fl.
-- Otherwise it will return nil
--
-- @return Full path to .fl directory on success, nil otherwise.
function _M.getRootPath()
    local pwd = FileSystem.currentdir()
    if not pwd then
        return nil
    end

    local parents = function(directory)
        local iterator = function(initial, current)
            if "." == current then
                return initial
            elseif not current or "" == current then
                return nil
            end

            return _M.getParent(current)
        end

        return iterator, directory, "."
    end

    for parent in parents(pwd) do
        for child in FileSystem.dir(parent) do
            if "." ~= child
                and ".." ~= child
                and "directory" == FileSystem.attributes(table.concat({parent, child}, "/"), "mode")
            then
                if ".fl" == child then
                    return table.concat({parent, child}, "/")
                end
            end
        end
    end

    return nil
end

--- Creates path string from parts.
-- @param (...) subparts of path to generate.
-- @return  String with full generated path.
function _M.path(...)
    function normalize(path)
        if not path then
            return path
        end

        return (path:gsub("\\", "/"):gsub("//", "/"))
    end

    local path = {}

    for index = 1, select("#", ...), 1 do
        local argument = select(index, ...)
        if argument and "string" ~= type(argument) then
            error("Invalid argument type (expected string): " .. type(argument), 2)
        end
        if argument and "" ~= argument then
            path[#path + 1] = argument
        end
    end

    if 0 < #path then
        return normalize("/" .. table.concat( path, "/" ))
    else
        return ""
    end
end

--- Generates full path inside .fl for card or meta files.
-- @param root Root folder of file inside .fl ("cards", "meta", "boards") as string.
-- @param prefix Name of subfolder inside the root as string.
-- @return string with full path with trailing / on success, nil otherwise
local function generatePath(root, prefix)
    local pwd = _M.getRootPath()
    if not pwd then
        return nil
    end

    local path = { pwd }
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
function _M.createDir(path)
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
function _M.createCardFile(root, prefix, infix, suffix, content)
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

    if not _M.createDir(data.path) then
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
function _M.serializeMeta(card)
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

return _M
