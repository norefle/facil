--[[----------------------------------------------------------------------------
--- @file facil.lua
--- @brief Entry point of fácil module.
----------------------------------------------------------------------------]]--

local Core = require "facil.core"

local _M = { }

--- Current version.
_M.VERSION = "0.0.1"

--- Official name of fácil.
_M.NAME = "fácil"

--- @brief Initializes fácil.
--
-- Creates fácil's file system layout inside selected directory and all required files.
-- File system layout is:
--      ROOT/                           - Selected root, passed as root param.
--          .fl/                        - Root directory for entire fácil.
--              boards/                 - Root directory for boards.
--                  backlog/            - Initial board, all new tasks are sticked here.
--                  progress/           - All task which are in progress are sticked here.
--                  done/               - All finished tasks.
--              cards/                  - All tasks ever created.
--              meta/                   - Description of tasks.
--              config                  - Local configuration file.
--
-- @param root Path to the root directory, where to initialize fl.
--
-- @retval true - on success
-- @retval nil, string - on error, where string contains detailed description.
_M.init = Core.init

--- @brief Creates new card
--
-- Card consists of three files:
--   1 Card file - text file with markdown content contained description of task.
--   2 Meta data file - text file in lua format with meta data described card itself.
--   3 Status file - empty file in boards pointed to current status of the card.
-- All these files are placed inside .fl directory (by default).
--
-- @param name Short and descriptive name of new card. (string, mandatory)
--
-- @retval true, string - on success, where string is the uuid of new card.
-- @retval nil, string - on error, where string contains detailed description.
_M.create = Core.create

return _M
