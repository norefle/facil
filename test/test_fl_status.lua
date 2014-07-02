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

        local oldReuquire = require
        require = function(name)
            if name then
                return {
                    id = name,
                    name = "Task #1",
                    created = 123
                }
            else
                return oldReuquire(name)
            end
        end

        local board = fl.status()
        assert.is.equal("table", type(board[1].tasks))
        assert.is.equal(2, #board[1].tasks)
        assert.is.equal("Task #1", board[1].tasks[1].name)

        require = oldReuquire

        revertMocks(backup, lfs, nil, io)
    end)

    pending("returns task in ascending order by moving date", function()
        local backup = createMocks(lfs, nil, io)

        local oldReuquire = require
        require = function(name)
            if "/xyz/.fl/meta/ta/sk_1" == name then
                return {
                    id = name,
                    name = "Task #1",
                    created = 123
                }

            elseif "/xyz/.fl/meta/ta/sk_2" == name then
                return {
                    id = name,
                    name = "Task #2",
                    created = 12
                }
            else
                return oldReuquire(name)
            end
        end

        local board = fl.status()
        assert.is.equal("table", type(board[1].tasks))
        assert.is.equal(2, #board[1].tasks)
        assert.is.equal(13, board[1].tasks[1].moved)
        assert.is.equal(456, board[1].tasks[2].moved)

        require = oldReuquire

        revertMocks(backup, lfs, nil, io)
    end)
end)
