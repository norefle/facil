--[[----------------------------------------------------------------------------
--- @file facil.lua
--- @brief Entry point of fácil module.
----------------------------------------------------------------------------]]--

local Create = require "facil.create"
local Init = require "facil.init"
local Status = require "facil.status"
local Move = require "facil.move"

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
_M.init = Init.init

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
_M.create = Create.create

--- Returns current status of the board with tasks on it.
-- @return Board description.
-- @note Here is the example of returned board:
--      @code
--          board = {
--              -- Lane number 0, with flag initial = true
--              {
--                  name = "Backlog",
--                  -- Work in progress limit (set in config file)
--                  wip = 12,
--                  -- Board priority (0 - backlog, #board - done, 1 - custom boards)
--                  priority = 0,
--                  -- Full path to lane
--                  path = /some/path/to/.fl/boards/Backlog,
--                  -- Array of tasks, ordered by date (asc)
--                  tasks = {
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
_M.status = Status.status

---
_M.move = Move.move

return _M
