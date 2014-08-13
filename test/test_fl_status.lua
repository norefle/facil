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
        fl = nil
        package.loaded["facil"] = nil
        package.loaded["facil.core"] = nil
        package.loaded["facil.create"] = nil
        package.loaded["facil.init"] = nil
        package.loaded["facil.status"] = nil

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

        local board, err = fl.status()
        assert.is.equal(3, #board)
        assert.is.equal("backlog", board[1].name)

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

    it("returns task in ascending order by moving date", function()
        local backup = createMocks(lfs, nil, io)
        local oldOpen = io.open
        io.open = function(file, type)
            local time = 17
            if file:find("task_2") then
                time = 13
            elseif file:find("task_1") then
                time = 456
            end
            return {
                read = function(...) return tostring(time) end,
                close = function(...) end
            }
        end

        local board = fl.status()

        assert.is.equal("table", type(board[1].tasks))
        assert.is.equal(2, #board[1].tasks)
        assert.is.equal(13, board[1].tasks[1].moved)
        assert.is.equal(456, board[1].tasks[2].moved)

        io.open = oldOpen

        revertMocks(backup, lfs, nil, io)
    end)

    it("returns valid WIP for board", function()
        local backup = createMocks(lfs, nil, io)

        local board = fl.status()

        assert.is.equal("progress", board[2].name)
        assert.is.equal(12, board[2].wip)

        revertMocks(backup, lfs, nil, io)
    end)

    it("returns boards in order of priority", function()
        local backup = createMocks(lfs, nil, io)

        local board = fl.status()

        assert.is.equal("backlog", board[1].name)
        assert.is.equal(0, board[1].priority)
        assert.is.equal("progress", board[2].name)
        assert.is.equal(1, board[2].priority)
        assert.is.equal("done", board[3].name)
        assert.is.equal(3, board[3].priority)

        revertMocks(backup, lfs, nil, io)
    end)
end)
