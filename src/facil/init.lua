--[[----------------------------------------------------------------------------
--- @file init.lua
--- @brief Entry point of fácil module.
----------------------------------------------------------------------------]]--

local lfs = require "lfs"
local math = require "math"
local io = require "io"

local _M = {}

--- Creates new card
-- @param cardName Short descriptive name of card.
-- @retval true, nil - on success.
-- @retval nil, string - on error, where string contains detailed description.
function _M.create(cardName)
    if not cardName or "string" ~= type(cardName) then
        return nil, "Invalid argument"
    end

    return true
end

--- Current version.
_M.VERSION = "0.0.1"

--- Official name of fácil.
_M.NAME = "fácil"

return _M
