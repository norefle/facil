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

    setup(function()
        -- Load and configure fácil module.
        fl = require "facil"
        -- Set random generation in the same state every time.
        math.randomseed(0)
    end)

    teardown(function()
        -- Unload fácil module.
        fl = nil
    end)

    it("exists", function()
        assert.is.not_equal(fl.create, nil)
    end)

    it("fails with empty arguments", function()
        local result, details = fl.create()
        assert.is.equal(result, nil)
        assert.is.equal(details, "Invalid argument")
    end)

    it("returns error on invalid file creation", function()
        io = mock(io, true)

        local result, details = fl.create("name")
        assert.is.equal(result, nil)
        assert.is.equal(details:find("Can't create temp file"), 1)

        io = unwrap(io)
    end)
end)
