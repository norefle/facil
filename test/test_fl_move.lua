--[[----------------------------------------------------------------------------
--- @file test_fl_move.lua
--- @brief Unit test for fl move command.
----------------------------------------------------------------------------]]--

local Helpers = require "test.helpers"

local unwrap = Helpers.unwrap
local createMocks = function(...) return Helpers.createMocks(mock, ...) end
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

        local code = fl.move(TASK_ID)

        os.rename = backup.os.rename

        assert.is.equal(true, code)
        assert.stub(os.rename).was.called()
        assert.stub(os.rename).was.called_with(
            ROOT .. "/.fl/boards/backlog/" .. TASK_ID,
            ROOT .. "/.fl/boards/progress/" .. TASK_ID
        )

        revertMocks(backup, lfs, nil, io, os)
    end)

    it("returns success on valid prefix of task id without lane name", function()
        local backup = createMocks(lfs, nil, io, os)

        local code = fl.move(TASK_ID:sub(1, 7)) -- aaaa-bb

        os.rename = backup.os.rename

        assert.is.equal(true, code)
        assert.stub(os.rename).was.called()
        assert.stub(os.rename).was.called_with(
            ROOT .. "/.fl/boards/backlog/" .. TASK_ID,
            ROOT .. "/.fl/boards/progress/" .. TASK_ID
        )

        revertMocks(backup, lfs, nil, io, os)
    end)

    it("returns error on ambiguous partial id", function()
        local backup = createMocks(lfs, nil, io, os)

        local code, description = fl.move("task")

        assert.is.equal(nil, code)
        assert.is.equal("Task id is ambiguous: task", description)

        revertMocks(backup, lfs, nil, io, os)
    end)

    it("uses partial id as prefix only", function()
        local backup = createMocks(lfs, nil, io, os)

        local code, description = fl.move(TASK_ID:sub(6, 9)) -- bbbb <- infix of aaaa-bbbb-...

        assert.is.equal(nil, code)
        assert.is.equal("There is no task with id: bbbb", description)

        revertMocks(backup, lfs, nil, io, os)
    end)

    it("returns error for moving task in a final board without explicit lane name", function()
        local backup = createMocks(lfs, nil, io, os)

        local code, description = fl.move("task_done")

        assert.is.equal(nil, code)
        assert.is.equal("Task is already on final board: done/task_done_1", description)

        revertMocks(backup, lfs, nil, io, os)
    end)

    it("moves task to the existed lane by its name", function()
        local backup = createMocks(lfs, nil, io, os)

        local code, description = fl.move("task_done_1", "backlog")

        os.rename = backup.os.rename

        assert.is.equal(true, code)
        assert.stub(os.rename).was.called()
        assert.stub(os.rename).was.called_with(
            ROOT .. "/.fl/boards/done/task_done_1",
            ROOT .. "/.fl/boards/backlog/task_done_1"
        )

        revertMocks(backup, lfs, nil, io, os)
    end)
end)
