--[[----------------------------------------------------------------------------
--- @file test_fl_create.lua
--- @brief Unit test for fl create command.
----------------------------------------------------------------------------]]--

local Helpers = require "test.helpers"

local UUID = Helpers.FAKE_UUID
local UUID_HEAD = Helpers.FAKE_UUID_HEAD
local UUID_TAIL = Helpers.FAKE_UUID_TAIL
local ROOT = Helpers.FAKE_ROOT
local TIMESTAMP = Helpers.FAKE_OS_TIME
local createMocks = Helpers.createMocks
local unwrap = Helpers.unwrap
local restoreBackup = Helpers.restoreBackup
local revertMocks = Helpers.revertMocks

local CARDS = ROOT .. "/.fl/cards/"
local META = ROOT .. "/.fl/meta/"
local BOARDS = ROOT .. "/.fl/boards/"
local CARD_MD = CARDS .. UUID_HEAD .. "/" .. UUID_TAIL .. ".md"

describe("fácil's create command", function()
    local fl -- Core module of fácil.
    local uuid -- uuid library.
    local lfs -- LuaFileSystem library.

    before_each(function()
        -- Load and configure fácil module.
        fl = require "facil"

        -- Loads explicitly system libraries for mocking.
        uuid = require "uuid"
        lfs = require "lfs"
    end)

    after_each(function()
        -- Unload modules.
        fl, package.loaded["facil"], package.loaded["facil.core"] = nil, nil, nil
        uuid, package.loaded["uuid"] = nil, nil
        lfs, package.loaded["lfs"] = nil, nil

        -- Removes all stubs and spies.
        unwrap(io)
        unwrap(os)
    end)

    it("exists", function()
        assert.is.not_equal(fl.create, nil)
    end)

    it("fails with empty arguments", function()
        local result, details = fl.create()
        assert.is.equal(result, nil)
        assert.is.equal(details, "Invalid argument.")
    end)

    it("returns error on invalid file creation", function()
        local backup = createMocks(lfs, uuid, nil, os)
        io = mock(io, true)

        local result, details = fl.create("name")
        assert.is.equal(result, nil)
        assert.is.equal(details:find("Can't create file: "), 1)

        io = unwrap(io)
        os = unwrap(os)
        revertMocks(backup, lfs, uuid, nil, os)
    end)

    it("creates card and meta with valid names", function()
        local backup = createMocks(lfs, uuid, nil, os)
        io = mock(io, true)

        local result, details = fl.create("new card")
        -- Stub will return nil on io.open always,
        -- as result fl.create should fail
        assert.is.equal(result, nil)
        assert.is.equal(details:find("Can't create file: "), 1)

        -- Check that stub was called with correct arguments.
        assert.stub(io.open).was.called(1)
        assert.stub(io.open).was.called_with(CARD_MD, "w")

        io = unwrap(io)
        revertMocks(backup, lfs, uuid, nil, os)
    end)

    it("returns error if didn't get current directory", function()
        io = mock(io, true)
        lfs = mock(lfs, true)

        local result, description = fl.create("wrong")
        assert.is.equal(result, nil)
        assert.is.equal("Can't generate file name for card.", description)

        lfs = unwrap(lfs)
        io = unwrap(io)
    end)

    it("creates required directories", function()
        local backup = createMocks(lfs, uuid, nil, os)
        io = mock(io, true)

        fl.create("task #1")

        -- Restore stub from backup to be able to call was.called
        restoreBackup(backup, lfs)

        assert.stub(lfs.mkdir).was.called(1)
        assert.stub(lfs.mkdir).was.called_with(CARDS .. UUID_HEAD .. "/")

        io = unwrap(io)
        revertMocks(backup, lfs, uuid, nil, os)
    end)

    it("fills card with markdown template", function()
        local fileHistory = {}
        local backup = createMocks(lfs, uuid, io, os, fileHistory)

        fl.create("markdown test card")

        local template = require "facil.template.md"

        assert.is.not_equal(fileHistory.write, nil)
        assert.is.not_equal(fileHistory.write[1], nil)
        assert.is.not_equal(fileHistory.write[1][1], nil)
        assert.is.equal(template.value, fileHistory.write[1][1])

        revertMocks(backup, lfs, uuid, io, os)
    end)

    it("opens $EDITOR to edit just created card.", function()
        local backup = createMocks(lfs, uuid, io, os)

        fl.create("opens edior")

        assert.stub(os.execute).was.called(1)
        assert.stub(os.execute).was.called_with("$EDITOR " .. CARD_MD)

        revertMocks(backup, lfs, uuid, io, os)
    end)

    it("creates required directories for meta data", function()
        local backup = createMocks(lfs, uuid, io, os)

        fl.create("meta data")

        -- Restore stub from backup to be able to call was.called
        restoreBackup(backup, lfs)

        assert.stub(lfs.mkdir).was.called()
        assert.stub(lfs.mkdir).was.called_with(META .. UUID_HEAD .. "/")

        revertMocks(backup, lfs, uuid, io, os)
    end)

    it("creates metafile for card", function()
        local fileHistory = {}
        local backup = createMocks(lfs, uuid, io, os, fileHistory)

        local expected = [[
return {
    id = aaaa-bbbb-cccc-dddd,
    name = meta file,
    created = 1234567
}]]

        fl.create("meta file")

        assert.is.not_equal(fileHistory.write, nil)
        assert.is.not_equal(fileHistory.write[2], nil)
        assert.is.not_equal(fileHistory.write[2][1], nil)
        assert.is.equal(expected, fileHistory.write[2][1])

        revertMocks(backup, lfs, uuid, io, os)
    end)

    it("returns id of new card", function()
        local backup = createMocks(lfs, uuid, io, os)

        local code, id = fl.create("create returns id")

        assert.is.equal(true, code)
        assert.is.equal(UUID, id)

        Helpers.revertMocks(backup, lfs, uuid, io, os)
    end)

    it("sticks new card onto backlog board", function()
        local backup = createMocks(lfs, uuid, io, os)

        fl.create("new card to backlog")

        restoreBackup(backup, nil, nil, io)
        assert.stub(io.open).was.called_with(BOARDS .. "backlog/" .. UUID, "w")

        revertMocks(backup, lfs, uuid, io, os)
    end)

    it("puts timestamp into marker file inside backlog", function()
        local fileHistory = {}
        local backup = createMocks(lfs, uuid, io, os, fileHistory)

        fl.create("timestamp in backlog")

        assert.is.not_equal(fileHistory.write, nil)
        assert.is.not_equal(fileHistory.write[3], nil)
        assert.is.not_equal(fileHistory.write[3][1], nil)
        assert.is.equal(tostring(TIMESTAMP), fileHistory.write[3][1])

        revertMocks(backup, lfs, uuid, io, os)
    end)
end)
