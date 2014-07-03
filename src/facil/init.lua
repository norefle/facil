--[[----------------------------------------------------------------------------
--- @file create.lua
--- @brief fácil's init command.
----------------------------------------------------------------------------]]--

local Core = require "facil.core"

local Template = require "facil.template.default_config"

local _M = {}

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
        if not Core.createDir(path) then
            return nil, "Can't create directory: " .. path
        end
    end

    local configSuccess, configError =
        Core.createCardFile("", nil, "config", nil, Template.value)
    if not configSuccess then
        return nil, configError
    end

    return true
end

return _M
