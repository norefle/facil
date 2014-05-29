--[[----------------------------------------------------------------------------
--- @file test_fl_create.lua
--- @brief Unit test for fl create command.
----------------------------------------------------------------------------]]--

describe("fácil's create command", function()
    local fl -- Core module of fácil.

    setup(function()
        -- Load and configure fácil module.
        fl = require "facil"
    end)

    teardown(function()
        -- Unload fácil module.
        fl = nil
    end)

    it("exists", function()
        assert.is.not_equal(fl.create, nil)
    end)

    it("fails with empty arguments", function()
        assert.has.error(fl.create())
    end)
end)
