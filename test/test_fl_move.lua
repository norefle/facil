--[[----------------------------------------------------------------------------
--- @file test_fl_move.lua
--- @brief Unit test for fl move command.
----------------------------------------------------------------------------]]--

local Helpers = require "test.helpers"

local unwrap = Helpers.unwrap

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
end)
