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
-- @param root Root directory to start search from (optional).
--
-- It searches from root or from current directory (in case if root was nil)
-- to its parents up to file system root.
-- If .fl was found either within current directory or within parent directory
-- then it will return full path to directory contained .fl.
-- Otherwise it will return nil
--
-- @return Full path to .fl directory on success, nil otherwise.
function _M.getRootPath(root)
    local pwd = root or FileSystem.currentdir()
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
-- @return string - generated relative path.
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
        return normalize(table.concat( path, "/" ))
    else
        return ""
    end
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

    local flRoot = _M.getRootPath()
    if not flRoot then
        return nil, "Can't get fácil's root directory."
    end

    data.path = _M.path(flRoot, root, prefix)

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

--- Creates configuration file.
-- @param root Root directory to start looking for .fl (optional)
-- @param content Content of the config file.
-- @return true, string - success code and full config file name.
--         nil, string - failure code and error description.
function _M.createConfig(root, content)
    local flRoot = _M.getRootPath(root)
    if not flRoot then
        return nil, "Can't get fácil's root directory."
    end

    local fileName = _M.path(flRoot, "config")
    local file = io.open(fileName, "w")
    if not file then
        return nil, "Can't create file: " .. tostring(fileName)
    end

    file:write(content)
    file:close()

    return true, fileName
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

--- Splits task id into two component.
-- @param id Full uuid
-- @return string, string - prefix and postfix of id.
function _M.splitId(id)
    return id:sub(1, 2), id:sub(3)
end

--- Returns path (relative) for selected id.
-- @param id Full uuid of task.
-- @return string - path as prefix/postfix generated from id on success.
--         nil, error - otherwise
function _M.pathById(id)
    return _M.path(_M.splitId(id))
end

--- Returns time of moving the task to exact board.
-- @param board Name of board.
-- @param id Full task id.
-- @return number - unix timestamp of the date when task was moved to selected board on success,
--         nil, string - on error.
function _M.movedAt(board, id)
    local taskFileName = _M.path(_M.getRootPath(), "boards", board, id)
    local taskFile, err = io.open(taskFileName, "r")

    if not taskFile then
        return nil, "There is no requested task."
    end

    local date = taskFile:read("*a")
    taskFile:close()

    return tonumber(date)
end

return _M
