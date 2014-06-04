--[[----------------------------------------------------------------------------
--- @file default_config.lua
--- @brief Template for default local config file of fácil.
----------------------------------------------------------------------------]]--

return {

name = "Template.DefaultConfig",
version = "0.0.1",
value = [[
return {

-- Project code name, to show in board view.
project = "",

-- Default editor to open after task creation.
editor = "$EDITOR",

-- Boards in .fl/boards in following format:
--   name - is the name of a board
--   wip  - amount of task at the same task on a board
--   initial - new tasks will be sticked to this board
--   final - closed tasks will be sticked to this board
boards = {
    { name = "backlog", wip = 0, initial = true },
    { name = "progress", wip = 0 },
    { name = "done", wip = 0, final = true }
}

}
]]

}
