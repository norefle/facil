--[[----------------------------------------------------------------------------
--- @file test_fl_create.lua
--- @brief Unit test for fl create command.
----------------------------------------------------------------------------]]--

--- Reverts mocking of table (see busted's mock and stub functions)
-- @param origin Table previously wrapped with mock() function.
-- @return Table with removed stub wrappers.
local function unwrap(origin)
    for _, value in pairs(origin) do
        if "table" == type(value) and "function" == type(value.revert) then
            value:revert()
        end
    end

    return origin
end

--- Creates mocks for lfs, uuid and io
-- @param lfs Origin table for lfs module.
-- @param uuid Origin table for uuid module.
-- @param io Origin table for io module.
-- @param fileHistory Table for saving history of file operations. (optional)
-- @return Backup table for using in restore method.
local function createMocks(lfs, uuid, io, fileHistory)
    local backup = {}
    backup.lfs = {}
    backup.uuid = {}
    backup.io = {}

    if lfs then
        lfs = mock(lfs, true)

        backup.lfs.mkdir = lfs.mkdir
        lfs.mkdir = function(...)
            backup.lfs.mkdir(...)
            return true
        end

        backup.lfs.currentdir = lfs.currentdir
        lfs.currentdir = function(...)
            backup.lfs.currentdir(...)
            return "/xyz"
        end
    end

    if uuid then
        uuid = mock(uuid, true)

        backup.uuid.new = uuid.new
        uuid.new = function(...)
            backup.uuid.new(...)
            return "aaaa-bbbb-cccc-dddd"
        end
    end

    if io then
        io = mock(io, true)

        backup.io.open = io.open
        io.open = function(...)
            backup.io.open(...)
            return {
                read = function(self, ...)
                    return "file:data"
                end,

                close = function(self, ...)
                    return true
                end,

                write = function(self, ...)
                    if fileHistory then
                        fileHistory.write = fileHistory.write or {}
                        fileHistory.write[#fileHistory.write + 1] = {...}
                    end
                    return true
                end
            }
        end
    end

    return backup
end

--- Restores backup made by createMocks.
-- @param backup Table with backup savings.
-- @param lfs Mock table of lfs module.
-- @param uuid Mock table of uuid module.
-- @param io Mock table of io module.
local function restoreBackup(backup, lfs, uuid, io)
    if io then
        io.open = backup.io.open
    end

    if uuid then
        uuid.new = backup.uuid.new
    end

    if lfs then
        lfs.mkdir = backup.lfs.mkdir
        lfs.currentdir = backup.lfs.currentdir
    end
end

--- Reverts changes made by createMocks.
-- @param backup Table with backup savings.
-- @param lfs Mock table of lfs module.
-- @param uuid Mock table of uuid module.
-- @param io Mock table of io module.
local function revertMocks(backup, lfs, uuid, io)
    restoreBackup(backup, lfs, uuid, io)
    if io then
        io = unwrap(io)
    end

    if uuid then
        uuid = unwrap(uuid)
    end

    if lfs then
        lfs = unwrap(lfs)
    end
end

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
        fl, package.loaded["facil"] = nil, nil
        uuid, package.loaded["uuid"] = nil, nil
        lfs, package.loaded["lfs"] = nil, nil

        -- Removes all stubs and spies.
        unwrap(io)
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
        local backup = createMocks(lfs, uuid)
        io = mock(io, true)

        local result, details = fl.create("name")
        assert.is.equal(result, nil)
        assert.is.equal(details:find("Can't create file: "), 1)

        io = unwrap(io)
        revertMocks(backup, lfs, uuid)
    end)

    it("creates card and meta with valid names", function()
        local backup = createMocks(lfs, uuid)
        io = mock(io, true)

        local result, details = fl.create("new card")
        -- Stub will return nil on io.open always,
        -- as result fl.create should fail
        assert.is.equal(result, nil)
        assert.is.equal(details:find("Can't create file: "), 1)

        -- Check that stub was called with correct arguments.
        assert.stub(io.open).was.called(1)
        assert.stub(io.open).was.called_with("/xyz/.fl/cards/aa/aa-bbbb-cccc-dddd.md", "w")

        io = unwrap(io)
        revertMocks(backup, lfs, uuid)
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
        local backup = createMocks(lfs, uuid)
        io = mock(io, true)

        fl.create("task #1")

        -- Restore stub from backup to be able to call was.called
        restoreBackup(backup, lfs)

        assert.stub(lfs.mkdir).was.called(1)
        assert.stub(lfs.mkdir).was.called_with("/xyz/.fl/cards/aa/")

        io = unwrap(io)
        revertMocks(backup, lfs, uuid)
    end)

    it("fills card with markdown template", function()
        local fileHistory = {}
        local backup = createMocks(lfs, uuid, io, fileHistory)

        fl.create("markdown test card")

        local template = require "facil.template.md"

        assert.is.not_equal(fileHistory.write, nil)
        assert.is.not_equal(fileHistory.write[1], nil)
        assert.is.not_equal(fileHistory.write[1][1], nil)
        assert.is.equal(template.value, fileHistory.write[1][1])

        revertMocks(backup, lfs, uuid, io)
    end)
end)
