--[[----------------------------------------------------------------------------
--- @file test_fl_create.lua
--- @brief Unit test for fl create command.
----------------------------------------------------------------------------]]--

local Helpers = require "test.helpers"

local createMocks = Helpers.createMocks
local unwrap = Helpers.unwrap
local restoreBackup = Helpers.restoreBackup
local revertMocks = Helpers.revertMocks

local ROOT = Helpers.FAKE_ROOT

describe("fácil's status command", function()
    local fl -- Core module of fácil.
    local lfs -- LuaFileSystem library.

    before_each(function()
        -- Load and configure fácil module.
        fl = require "facil"

        -- Loads explicitly system libraries for mocking.
        lfs = require "lfs"
    end)

    after_each(function()
        -- Unload modules.
        fl, package.loaded["facil"], package.loaded["facil.core"] = nil, nil, nil
        lfs, package.loaded["lfs"] = nil, nil

        -- Removes all stubs and spies.
        unwrap(io)
        unwrap(os)
    end)

    it("exists", function()
        assert.is.not_equal(fl.status, nil)
    end)

    it("returns board with lanes as array", function()
        local backup = createMocks(lfs, nil, io)

        local board = fl.status()
        assert.is.equal(3, #board)
        assert.is.equal("Backlog", board[1].name)

        revertMocks(backup, lfs, nil, io)
    end)

    it("returns tasks per lane", function()
        local backup = createMocks(lfs, nil, io)

        local board = fl.status()
        assert.is.equal("table", type(board[1].tasks))
        assert.is.equal(2, #board[1].tasks)
        assert.is.equal("Task #1", board[1].tasks[1].name)

        revertMocks(backup, lfs, nil, io)
    end)
end)
