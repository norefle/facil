--[[----------------------------------------------------------------------------
--- @file test_fl_core.lua
--- @brief Unit test for fl core module configuration.
----------------------------------------------------------------------------]]--

describe("fácil configuration", function()
    local fl -- Core module of fácil.

    setup(function()
        -- Load and configure fácil module.
        fl = require "facil"
    end)

    teardown(function()
        -- Unload fácil module.
        fl = nil
    end)

    it("has VERSION", function()
        assert.has(fl.VERSION)
        assert.is.equal(fl.VERSION, "0.0.1")
    end)

    it("has NAME", function()
        assert.has(fl.NAME)
        assert.is.equal(fl.NAME, "fácil")
    end)
end)
