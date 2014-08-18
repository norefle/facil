--[[----------------------------------------------------------------------------
--- @file test_fl_move.lua
--- @brief Unit test for fl move command.
----------------------------------------------------------------------------]]--

local Helpers = require "test.helpers"

local unwrap = Helpers.unwrap
local createMocks = Helpers.createMocks
local unwrap = Helpers.unwrap
local restoreBackup = Helpers.restoreBackup
local revertMocks = Helpers.revertMocks

local ROOT = Helpers.FAKE_ROOT
local TASK_ID = Helpers.FAKE_UUID
local MOVE_TIME = Helpers.FAKE_OS_TIME

describe("fácil's move command", function()
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
        package.loaded["facil.move"] = nil

        lfs, package.loaded["lfs"] = nil, nil

        -- Removes all stubs and spies.
        unwrap(io)
        unwrap(os)
    end)

    it("exists", function()
        assert.is.not_equal(nil, fl.move)
    end)

    it("returns error on empty argument list", function()
        local code, description = fl.move()
        assert.is.equal(nil, code)
        assert.is.equal("Invalid task id: nil", description)
    end)

    it("returns error in case of error task id", function()
        local backup = createMocks(lfs, nil, io, os)

        local code, description = fl.move("invalid_id")
        assert.is.equal(nil, code)
        assert.is.equal("There is no task with id: invalid_id", description)

        revertMocks(backup, lfs, nil, io, os)
    end)

    it("returns success on valid task id without lane name", function()
        local backup = createMocks(lfs, nil, io, os)

        local code, description = fl.move("task_1")

        os.rename = backup.os.rename

        assert.is.equal(true, code)
        assert.stub(os.rename).was.called()
        assert.stub(os.rename).was.called_with(
            ROOT .. "/.fl/boards/backlog/" .. "task_1",
            ROOT .. "/.fl/boards/progress/" .. "task_1"
        )

        revertMocks(backup, lfs, nil, io, os)
    end)
end)
