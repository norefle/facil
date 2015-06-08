--[[----------------------------------------------------------------------------
--- @file create.lua
--- @brief fácil's init command.
----------------------------------------------------------------------------]]--

local Core = require "facil.core"

local Template = {
    config = require "facil.template.default_config",
    task = require "facil.template.md"
}

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
        root .. "/.fl/meta",
        root .. "/.fl/template"
    }

    for _, path in pairs(directories) do
        if not Core.createDir(path) then
            return nil, "Can't create directory: " .. path
        end
    end

    local success, errorCode = Core.createFile(root, Template.config.value, "config")
    if not success then
        return nil, errorCode
    end

    success, errorCode = Core.createFile(root, Template.task.value, Core.path("template", "task.lua"))
    if not success then
        return nil, errorCode
    end

    return true
end

return _M
