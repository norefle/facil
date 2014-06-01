--[[----------------------------------------------------------------------------
--- @file test_fl_create.lua
--- @brief Unit test for fl create command.
----------------------------------------------------------------------------]]--

--- Reverts mocking of table (see busted's mock and stub functions)
-- @param origin Table previously wrapped with mock() function.
-- @return Table with removed stub wrappers.
local function unwrap(origin)
    if not origin or "table" ~= type(origin) then
        return origin
    end

    for _, value in pairs(origin) do
        if "table" == type(value) and "function" == type(value.revert) then
            value:revert()
        end
    end

    return origin
end

--- Creates mocks for lfs, uuid and io
-- @param lfs Origin table for lfs module. (optional)
-- @param uuid Origin table for uuid module. (optional)
-- @param io Origin table for io module. (optional)
-- @param os Origin table for os module. (optional)
-- @param fileHistory Table for saving history of file operations. (optional)
-- @return Backup table for using in restore method.
local function createMocks(lfs, uuid, io, os, fileHistory)
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

    if os then
        os = mock(os, true)
        backup.os = backup.os or {}
        backup.os.time = os.time

        os.time = function(...)
            backup.os.time(...)
            return 1234567
        end
    end

    return backup
end

--- Restores backup made by createMocks.
-- @param backup Table with backup savings.
-- @param lfs Mock table of lfs module.
-- @param uuid Mock table of uuid module.
-- @param io Mock table of io module.
-- @param os Mock table of os module.
local function restoreBackup(backup, lfs, uuid, io, os)
    if os then
        os.time = backup.os.time
    end

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
-- @param lfs Mock table of lfs module. (optional)
-- @param uuid Mock table of uuid module. (optional)
-- @param io Mock table of io module. (optional)
-- @param os Mock table of io module. (optional)
local function revertMocks(backup, lfs, uuid, io, os)
    restoreBackup(backup, lfs, uuid, io, os)

    os = unwrap(os)
    io = unwrap(io)
    uuid = unwrap(uuid)
    lfs = unwrap(lfs)
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
        assert.stub(io.open).was.called_with("/xyz/.fl/cards/aa/aa-bbbb-cccc-dddd.md", "w")

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
        assert.stub(lfs.mkdir).was.called_with("/xyz/.fl/cards/aa/")

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
        assert.stub(os.execute).was.called_with("$EDITOR /xyz/.fl/cards/aa/aa-bbbb-cccc-dddd.md")

        revertMocks(backup, lfs, uuid, io, os)
    end)

    it("creates required directories for meta data", function()
        local backup = createMocks(lfs, uuid, io, os)

        fl.create("meta data")

        -- Restore stub from backup to be able to call was.called
        restoreBackup(backup, lfs)

        assert.stub(lfs.mkdir).was.called(2)
        assert.stub(lfs.mkdir).was.called_with("/xyz/.fl/meta/aa/")

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
end)
