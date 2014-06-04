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

describe("fácil's init command", function()
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
        assert.is.not_equal(fl.init, nil)
    end)

    it("returns error on empty argument", function()
        local success, description = fl.init(nil)
        assert.is.equal(nil, success)
        assert.is.equal("Invalid argument.", description)
    end)

    it("returns success on valid argument", function()
        local backup = createMocks(lfs, nil, io)

        local success, description = fl.init(ROOT)
        assert.is.equal(true, success)
        assert.is.equal(nil, description)

        revertMocks(backup, lfs, nil, io)
    end)

    it("creates .fl directory", function()
        local backup = createMocks(lfs, nil, io)
        local flRoot = ROOT .. "/.fl"

        fl.init(ROOT)
        restoreBackup(backup, lfs)

        assert.stub(lfs.mkdir).was.called()
        assert.stub(lfs.mkdir).was.called_with(flRoot)

        revertMocks(backup, lfs, nil, io)
    end)

    it("creates .fl/meta and .fl/cards directories", function()
        local backup = createMocks(lfs, nil, io)
        local meta = ROOT .. "/.fl/meta"
        local cards = ROOT .. "/.fl/cards"


        fl.init(ROOT)
        restoreBackup(backup, lfs)

        assert.stub(lfs.mkdir).was.called()
        assert.stub(lfs.mkdir).was.called_with(cards)
        assert.stub(lfs.mkdir).was.called_with(meta)

        revertMocks(backup, lfs, nil, io)
    end)

    it("creates all .fl/boards directories", function()
        local backup = createMocks(lfs, nil, io)
        local boards = ROOT .. "/.fl/boards"
        local backlog = boards .. "/backlog"
        local progress = boards .. "/progress"
        local done = boards .. "/done"


        fl.init(ROOT)
        restoreBackup(backup, lfs)

        assert.stub(lfs.mkdir).was.called()
        assert.stub(lfs.mkdir).was.called_with(boards)
        assert.stub(lfs.mkdir).was.called_with(backlog)
        assert.stub(lfs.mkdir).was.called_with(progress)
        assert.stub(lfs.mkdir).was.called_with(done)

        revertMocks(backup, lfs, nil, io)
    end)
end)
