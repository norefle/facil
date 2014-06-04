--[[----------------------------------------------------------------------------
--- @file helpers.lua
--- @brief Helpers functions and constants for unit tests.
----------------------------------------------------------------------------]]--

--- Test.Helpers module
local Helpers = {}

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

--- Fake UUID for mock of uuid library.
Helpers.FAKE_UUID = "aaaa-bbbb-cccc-dddd"
Helpers.FAKE_UUID_HEAD = "aa"
Helpers.FAKE_UUID_TAIL = "aa-bbbb-cccc-dddd"

--- Fake root directory for lfs.currentdir
Helpers.FAKE_ROOT = "/xyz"
--- Fake current time as timestamp for os.time
Helpers.FAKE_OS_TIME = 1234567

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

--- Reverts mocking of table (see busted's mock and stub functions)
-- @param origin Table previously wrapped with mock() function.
-- @return Table with removed stub wrappers.
function Helpers.unwrap(origin)
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
function Helpers.createMocks(lfs, uuid, io, os, fileHistory)
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
            return Helpers.FAKE_ROOT
        end
    end

    if uuid then
        uuid = mock(uuid, true)

        backup.uuid.new = uuid.new
        uuid.new = function(...)
            backup.uuid.new(...)
            return Helpers.FAKE_UUID
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
            return Helpers.FAKE_OS_TIME
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
function Helpers.restoreBackup(backup, lfs, uuid, io, os)
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
function Helpers.revertMocks(backup, lfs, uuid, io, os)
    Helpers.restoreBackup(backup, lfs, uuid, io, os)

    os = Helpers.unwrap(os)
    io = Helpers.unwrap(io)
    uuid = Helpers.unwrap(uuid)
    lfs = Helpers.unwrap(lfs)
end

--------------------------------------------------------------------------------
-- Exports
--------------------------------------------------------------------------------

return Helpers
