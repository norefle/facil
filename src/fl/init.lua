--[[----------------------------------------------------------------------------
--- @file init.lua
--- @brief fácil cli: init command handler.
----------------------------------------------------------------------------]]--

local Fl = require "facil"

--- Cli wrapper for fl.init command.
-- @param rootPath Root path to init fl (string).
-- @return true on success
--         nil, error:string otherwise
local function init(rootPath)
    if not rootPath then
        return nil, "Error: root should be non empty to initialize fácil."
    end

    return Fl.init(rootPath)
end

--- Returns detailed description (string) help for init command.
local function help()
        return [[
fl init ROOT

Creates fácil's file system layout inside selected directory and all required files.
File system layout is:
  ROOT/                           - Selected root, passed as root param.
      .fl/                        - Root directory for entire fácil.
          boards/                 - Root directory for boards.
              backlog/            - Initial board, all new tasks are sticked here.
              progress/           - All task which are in progress are sticked here.
              done/               - All finished tasks.
          cards/                  - All tasks ever created.
          meta/                   - Description of tasks.
          config                  - Local configuration file.
]]
end

return {
    handler = init,
    help = help
}
