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
        io = mock(io, true)
        lfs = mock(lfs, true)

        local origin = {}
        origin.currentdir = lfs.currentdir
        origin.mkdir = lfs.mkdir

        lfs.currentdir = function() return "/home/fl" end
        lfs.mkdir = function() return true end

        local result, details = fl.create("name")
        assert.is.equal(result, nil)
        assert.is.equal(details:find("Can't create file: "), 1)

        lfs.currentdir = origin.currentdir
        lfs.mkdir = origin.mkdir

        lfs = unwrap(lfs)
        io = unwrap(io)
    end)

    it("creates card and meta with valid names", function()
        io = mock(io, true)
        lfs = mock(lfs, true)

        local origin = {}

        origin.new = uuid.new
        uuid.new = function() return "aaa-bbb-ccc-ddd" end

        origin.currentdir = lfs.currentdir
        lfs.currentdir = function() return "/xyz" end

        origin.mkdir = lfs.mkdir
        lfs.mkdir = function() return true end

        local result, details = fl.create("new card")
        -- Stub will return nil on io.open always,
        -- as result fl.create should fail
        assert.is.equal(result, nil)
        assert.is.equal(details:find("Can't create file: "), 1)

        -- Check that stub was called with correct arguments.
        assert.stub(io.open).was.called(1)
        assert.stub(io.open).was.called_with("/xyz/.fl/cards/aa/a-bbb-ccc-ddd.md", "w")

        lfs.mkdir = origin.mkdir
        lfs.currentdir = origin.currentdir
        uuid.new = origin.new

        lfs = unwrap(lfs)
        io = unwrap(io)
    end)

    it("returns error if didn't get current directory", function()
        lfs = mock(lfs, true)

        local result, description = fl.create("wrong")
        assert.is.equal(result, nil)
        assert.is.equal("Can't generate file name for card.", description)

        unwrap(lfs)
    end)

    it("creates required directories", function()
        lfs = mock(lfs, true)

        local origin = {
            currentdir = lfs.currentdir,
            mkdir = lfs.mkdir,
            new = uuid.new
        }

        lfs.currentdir = function() return "/home/facil" end
        lfs.mkdir = function(...)
            origin.mkdir(...)
            return true
        end
        uuid.new = function() return "1234-5678-9abc-ef01" end

        local result, description = fl.create("task #1")

        lfs.mkdir = origin.mkdir

        assert.stub(lfs.mkdir).was.called(1)
        assert.stub(lfs.mkdir).was.called_with("/home/facil/.fl/cards/12/")

        uuid.new = origin.new
        lfs.currentdir = origin.currentdir
        unwrap(lfs)
    end)
end)
